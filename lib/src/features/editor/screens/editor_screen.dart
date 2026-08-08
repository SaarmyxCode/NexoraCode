import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';

import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/features/editor/data/code_analysis_service.dart';
import 'package:ncode/src/features/editor/domain/tab_item.dart';
import 'package:ncode/src/features/editor/presentation/controllers/fast_code_controller.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/features/editor/presentation/widgets/activity_bar.dart';
import 'package:ncode/src/features/editor/presentation/widgets/file_explorer.dart';
import 'package:ncode/src/features/editor/presentation/widgets/search_panel.dart';
import 'package:ncode/src/features/editor/presentation/widgets/git_panel.dart';
import 'package:ncode/src/features/editor/presentation/widgets/embedded_terminal.dart';
import 'package:ncode/src/features/editor/presentation/widgets/status_bar.dart';
import 'package:ncode/src/features/editor/presentation/widgets/tab_bar_header.dart';

class NcodeEditorScreen extends ConsumerStatefulWidget {
  const NcodeEditorScreen({super.key});

  @override
  ConsumerState<NcodeEditorScreen> createState() => _NcodeEditorScreenState();
}

class _NcodeEditorScreenState extends ConsumerState<NcodeEditorScreen> {
  FastCodeController? _codeController;
  int _selectedActivityIndex = 0;
  int _currentLine = 1;
  int _currentColumn = 1;
  bool _isTerminalOpen = false;
  List<CodeDiagnostic> _diagnostics = [];

  void _updateController(String text, String filePath) {
    _codeController?.dispose();
    _codeController = FastCodeController(text: text);
    _codeController!.addListener(() => _onCodeChanged(filePath));
    _runAnalysis(text, filePath);
    setState(() {});
  }

  void _runAnalysis(String text, String filePath) {
    final language = CodeAnalysisService.detectLanguage(filePath);
    setState(() {
      _diagnostics = CodeAnalysisService.analyzeCode(text, language);
    });
  }

  void _onCodeChanged(String filePath) {
    if (_codeController == null) return;

    final text = _codeController!.text;
    final selection = _codeController!.selection;

    if (selection.isValid && selection.isCollapsed) {
      final cursorOffset = selection.baseOffset;
      if (cursorOffset <= text.length) {
        final textBeforeCursor = text.substring(0, cursorOffset);
        final lines = textBeforeCursor.split('\n');

        setState(() {
          _currentLine = lines.length;
          _currentColumn = lines.last.length + 1;
        });
      }
    }

    _codeController!.onTextChangedDebounced(() {
      _runAnalysis(text, filePath);
      final tabs = ref.read(openTabsProvider);
      final activeIndex = ref.read(activeTabIndexProvider);
      if (activeIndex != null && activeIndex < tabs.length) {
        final currentTab = tabs[activeIndex];
        if (currentTab.content != text) {
          currentTab.content = text;
          if (!currentTab.isModified) {
            currentTab.isModified = true;
            ref.read(openTabsProvider.notifier).state = [...tabs];
          }
        }
      }
    });
  }

  String _formatCurrentCode() {
    final activeIndex = ref.read(activeTabIndexProvider);
    final tabs = ref.read(openTabsProvider);
    if (activeIndex != null &&
        activeIndex < tabs.length &&
        _codeController != null) {
      final tab = tabs[activeIndex];
      final language = CodeAnalysisService.detectLanguage(tab.path);
      final formatted = CodeAnalysisService.formatCode(
        _codeController!.text,
        language,
      );

      _codeController!.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      tab.content = formatted;
      return formatted;
    }
    return _codeController?.text ?? '';
  }

  void _saveCurrentFile() async {
    final activeIndex = ref.read(activeTabIndexProvider);
    final tabs = ref.read(openTabsProvider);

    if (activeIndex != null &&
        activeIndex < tabs.length &&
        _codeController != null) {
      final contentToSave = _formatCurrentCode();
      final tab = tabs[activeIndex];

      final success = await FileService.saveFileContent(
        tab.path,
        contentToSave,
      );

      if (success) {
        tab.isModified = false;
        ref.read(openTabsProvider.notifier).state = [...tabs];
        _runAnalysis(contentToSave, tab.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Guardado'),
              duration: const Duration(milliseconds: 600),
              backgroundColor: NexoraColors.surfaceElevated,
            ),
          );
        }
      }
    }
  }

  void _openFile(String path, String name) async {
    final tabs = ref.read(openTabsProvider);
    final existingIndex = tabs.indexWhere((tab) => tab.path == path);

    if (existingIndex != -1) {
      ref.read(activeTabIndexProvider.notifier).state = existingIndex;
      _updateController(tabs[existingIndex].content, path);
    } else {
      final content = await FileService.getFileContent(path);
      final newTab = TabItem(path: path, name: name, content: content);
      ref.read(openTabsProvider.notifier).state = [...tabs, newTab];
      final newIndex = tabs.length;
      ref.read(activeTabIndexProvider.notifier).state = newIndex;
      _updateController(content, path);
    }
  }

  void _closeTab(int index) {
    final tabs = List<TabItem>.from(ref.read(openTabsProvider));
    tabs.removeAt(index);
    ref.read(openTabsProvider.notifier).state = tabs;

    final activeIndex = ref.read(activeTabIndexProvider);
    if (tabs.isEmpty) {
      ref.read(activeTabIndexProvider.notifier).state = null;
      _codeController?.dispose();
      _codeController = null;
      _diagnostics = [];
      setState(() {});
    } else if (activeIndex != null) {
      final newIndex = index >= tabs.length ? tabs.length - 1 : index;
      ref.read(activeTabIndexProvider.notifier).state = newIndex;
      _updateController(tabs[newIndex].content, tabs[newIndex].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(openTabsProvider);
    final activeIndex = ref.watch(activeTabIndexProvider);
    final activeTab = (activeIndex != null && activeIndex < tabs.length)
        ? tabs[activeIndex]
        : null;

    final errors = _diagnostics
        .where((d) => d.type == DiagnosticType.error)
        .length;
    final warnings = _diagnostics
        .where(
          (d) =>
              d.type == DiagnosticType.warning || d.type == DiagnosticType.info,
        )
        .length;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _saveCurrentFile,
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          shift: true,
          alt: true,
        ): () {
          _formatCurrentCode();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Código formateado'),
                duration: const Duration(milliseconds: 600),
                backgroundColor: NexoraColors.surfaceElevated,
              ),
            );
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: NexoraColors.background,
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ActivityBar(
                      selectedIndex: _selectedActivityIndex,
                      onSelect: (index) {
                        setState(() {
                          _selectedActivityIndex = index;
                        });
                      },
                    ),
                    if (_selectedActivityIndex == 0)
                      FileExplorer(onFileSelected: _openFile)
                    else if (_selectedActivityIndex == 1)
                      const SearchPanel()
                    else if (_selectedActivityIndex == 2)
                      const GitPanel(),
                    Expanded(
                      child: Column(
                        children: [
                          TabBarHeader(
                            onSave: _saveCurrentFile,
                            onCloseTab: _closeTab,
                            onTabSelected: (index) {
                              ref.read(activeTabIndexProvider.notifier).state =
                                  index;
                              final currentTabs = ref.read(openTabsProvider);
                              _updateController(
                                currentTabs[index].content,
                                currentTabs[index].path,
                              );
                            },
                          ),
                          Divider(height: 1, color: NexoraColors.border),
                          Expanded(
                            child: Container(
                              color: NexoraColors.background,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: _codeController == null
                                  ? Center(
                                      child: Text(
                                        'NCODE',
                                        style: TextStyle(
                                          fontFamily: 'Gliker',
                                          color: NexoraColors.textMuted,
                                          fontSize: 28,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    )
                                  : KeyboardListener(
                                      focusNode: FocusNode(),
                                      onKeyEvent: (KeyEvent event) {
                                        if (event is KeyDownEvent &&
                                            event.character != null) {
                                          _codeController!.handleAutoClosePairs(
                                            event.character!,
                                          );
                                        }
                                      },
                                      child: TextField(
                                        controller: _codeController!,
                                        maxLines: null,
                                        expands: true,
                                        keyboardType: TextInputType.multiline,
                                        autofocus: true,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        style: TextStyle(
                                          fontFamily: 'Cascadia Code',
                                          fontSize: 13,
                                          height: 1.4,
                                          color: NexoraColors.textPrimary,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          if (_isTerminalOpen)
                            EmbeddedTerminal(
                              onClose: () =>
                                  setState(() => _isTerminalOpen = false),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StatusBar(
                activeFilePath: activeTab?.path,
                line: _currentLine,
                column: _currentColumn,
                errorCount: errors,
                warningCount: warnings,
                onToggleTerminal: () =>
                    setState(() => _isTerminalOpen = !_isTerminalOpen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
