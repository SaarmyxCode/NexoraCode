import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/rust/api/file_system.dart';
import 'package:ncode/src/rust/frb_generated.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/rust.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const ProviderScope(child: NcodeApp()));
}

final currentPathProvider = StateProvider<String>((ref) => '/home');
final activeFilePathProvider = StateProvider<String?>((ref) => null);
final isModifiedProvider = StateProvider<bool>((ref) => false);

class NcodeApp extends StatelessWidget {
  const NcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ncode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: NexoraColors.background,
        colorScheme: const ColorScheme.dark(
          surface: NexoraColors.surface,
          primary: NexoraColors.accent,
        ),
      ),
      home: const NcodeEditorScreen(),
    );
  }
}

class NcodeEditorScreen extends ConsumerStatefulWidget {
  const NcodeEditorScreen({super.key});

  @override
  ConsumerState<NcodeEditorScreen> createState() => _NcodeEditorScreenState();
}

class _NcodeEditorScreenState extends ConsumerState<NcodeEditorScreen> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    _initCodeController("");
  }

  void _initCodeController(String text, {String? filePath}) {
    final mode = _getLanguageMode(filePath);
    _codeController?.dispose();
    _codeController = CodeController(text: text, language: mode);

    _codeController!.addListener(() {
      if (!ref.read(isModifiedProvider)) {
        ref.read(isModifiedProvider.notifier).state = true;
      }
    });
    setState(() {});
  }

  dynamic _getLanguageMode(String? filePath) {
    if (filePath == null) return null;
    if (filePath.endsWith('.dart')) return dart;
    if (filePath.endsWith('.rs')) return rust;
    if (filePath.endsWith('.json')) return json;
    if (filePath.endsWith('.js') || filePath.endsWith('.ts')) return javascript;
    if (filePath.endsWith('.py')) return python;
    return null;
  }

  void _saveCurrentFile() async {
    final filePath = ref.read(activeFilePathProvider);
    if (filePath != null && _codeController != null) {
      final success = await writeFileContent(
        filePath: filePath,
        content: _codeController!.text,
      );
      if (success) {
        ref.read(isModifiedProvider.notifier).state = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Archivo guardado correctamente'),
              duration: Duration(seconds: 1),
              backgroundColor: NexoraColors.surfaceElevated,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(currentPathProvider);
    final activeFile = ref.watch(activeFilePathProvider);
    final isModified = ref.watch(isModifiedProvider);

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
              Container(
                width: 260,
                decoration: const BoxDecoration(
                  color: NexoraColors.surface,
                  border: Border(
                    right: BorderSide(color: NexoraColors.border, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: NexoraColors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.folder_outlined,
                            size: 16,
                            color: NexoraColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentPath,
                              style: const TextStyle(
                                color: NexoraColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.drive_file_move_outlined,
                              size: 16,
                              color: NexoraColors.textSecondary,
                            ),
                            onPressed: () {
                              final parent = SystemPath.getParent(currentPath);
                              if (parent != null) {
                                ref.read(currentPathProvider.notifier).state =
                                    parent;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<FileEntry>>(
                        future: readDirectory(dirPath: currentPath),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          final items = snapshot.data!;
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                leading: Icon(
                                  item.isDir
                                      ? Icons.folder
                                      : Icons.insert_drive_file_outlined,
                                  size: 16,
                                  color: item.isDir
                                      ? NexoraColors.accent
                                      : NexoraColors.textMuted,
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: item.path == activeFile
                                        ? NexoraColors.textPrimary
                                        : NexoraColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () async {
                                  if (item.isDir) {
                                    ref
                                            .read(currentPathProvider.notifier)
                                            .state =
                                        item.path;
                                  } else {
                                    ref
                                        .read(activeFilePathProvider.notifier)
                                        .state = item
                                        .path;
                                    final content = await readFileContent(
                                      filePath: item.path,
                                    );
                                    ref
                                            .read(isModifiedProvider.notifier)
                                            .state =
                                        false;
                                    _initCodeController(
                                      content,
                                      filePath: item.path,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 38,
                      width: double.infinity,
                      color: NexoraColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            activeFile ?? 'Sin archivo abierto',
                            style: const TextStyle(
                              color: NexoraColors.textSecondary,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (isModified) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: NexoraColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (activeFile != null)
                            TextButton.icon(
                              onPressed: _saveCurrentFile,
                              icon: const Icon(
                                Icons.save_outlined,
                                size: 14,
                                color: NexoraColors.textSecondary,
                              ),
                              label: const Text(
                                'Guardar (Ctrl+S)',
                                style: TextStyle(
                                  color: NexoraColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: NexoraColors.border),
                    Expanded(
                      child: Container(
                        color: NexoraColors.background,
                        padding: const EdgeInsets.all(12),
                        child: _codeController == null
                            ? const Center(
                                child: Text(
                                  'Selecciona un archivo',
                                  style: TextStyle(
                                    color: NexoraColors.textMuted,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: CodeTheme(
                                  data: CodeThemeData(
                                    styles: monokaiSublimeTheme,
                                  ),
                                  child: CodeField(
                                    controller: _codeController!,
                                    textStyle: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
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

class SystemPath {
  static String? getParent(String path) {
    if (path == '/' || path.isEmpty) return null;
    final parts = path.split('/');
    parts.removeLast();
    if (parts.isEmpty || (parts.length == 1 && parts[0].isEmpty)) return '/';
    return parts.join('/');
  }
}

const monokaiSublimeTheme = {
  'root': TextStyle(
    backgroundColor: NexoraColors.background,
    color: NexoraColors.textPrimary,
  ),
  'keyword': TextStyle(color: Color(0xFFF92672), fontWeight: FontWeight.bold),
  'string': TextStyle(color: Color(0xFFE6DB74)),
  'number': TextStyle(color: Color(0xFFAE81FF)),
  'comment': TextStyle(
    color: NexoraColors.textMuted,
    fontStyle: FontStyle.italic,
  ),
  'class': TextStyle(color: Color(0xFF66D9EF)),
  'function': TextStyle(color: Color(0xFFA6E22E)),
};
