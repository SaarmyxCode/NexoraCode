import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';

import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/features/editor/domain/tab_item.dart';
import 'package:ncode/src/features/editor/presentation/controllers/fast_code_controller.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/features/editor/presentation/widgets/file_explorer.dart';
import 'package:ncode/src/features/editor/presentation/widgets/tab_bar_header.dart';

class NcodeEditorScreen extends ConsumerStatefulWidget {
  const NcodeEditorScreen({super.key});

  @override
  ConsumerState<NcodeEditorScreen> createState() => _NcodeEditorScreenState();
}

class _NcodeEditorScreenState extends ConsumerState<NcodeEditorScreen> {
  FastCodeController? _codeController;

  void _updateController(String text, String filePath) {
    _codeController?.dispose();

    _codeController = FastCodeController(text: text);

    _codeController!.addListener(() {
      final tabs = ref.read(openTabsProvider);
      final activeIndex = ref.read(activeTabIndexProvider);
      if (activeIndex != null && activeIndex < tabs.length) {
        final currentTab = tabs[activeIndex];
        _codeController!.onTextChangedDebounced(() {
          if (currentTab.content != _codeController!.text) {
            currentTab.content = _codeController!.text;
            if (!currentTab.isModified) {
              currentTab.isModified = true;
              ref.read(openTabsProvider.notifier).state = [...tabs];
            }
          }
        });
      }
    });
    setState(() {});
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
      setState(() {});
    } else if (activeIndex != null) {
      final newIndex = index >= tabs.length ? tabs.length - 1 : index;
      ref.read(activeTabIndexProvider.notifier).state = newIndex;
      _updateController(tabs[newIndex].content, tabs[newIndex].path);
    }
  }

  void _saveCurrentFile() async {
    final activeIndex = ref.read(activeTabIndexProvider);
    final tabs = ref.read(openTabsProvider);

    if (activeIndex != null &&
        activeIndex < tabs.length &&
        _codeController != null) {
      final tab = tabs[activeIndex];
      final success = await FileService.saveFileContent(
        tab.path,
        _codeController!.text,
      );

      if (success) {
        tab.isModified = false;
        ref.read(openTabsProvider.notifier).state = [...tabs];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Archivo guardado'),
              duration: Duration(milliseconds: 600),
              backgroundColor: NexoraColors.surfaceElevated,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _saveCurrentFile,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              FileExplorer(onFileSelected: _openFile),
              Expanded(
                child: Column(
                  children: [
                    TabBarHeader(
                      onSave: _saveCurrentFile,
                      onCloseTab: _closeTab,
                      onTabSelected: (index) {
                        ref.read(activeTabIndexProvider.notifier).state = index;
                        final tabs = ref.read(openTabsProvider);
                        _updateController(
                          tabs[index].content,
                          tabs[index].path,
                        );
                      },
                    ),
                    const Divider(height: 1, color: NexoraColors.border),
                    Expanded(
                      child: Container(
                        color: NexoraColors.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _codeController == null
                            ? const Center(
                                child: Text(
                                  'Ningún archivo abierto',
                                  style: TextStyle(
                                    color: NexoraColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : TextField(
                                controller: _codeController!,
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.multiline,
                                autofocus: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
