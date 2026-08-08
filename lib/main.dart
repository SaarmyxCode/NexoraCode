import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/rust/api/file_system.dart';
import 'package:ncode/src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar el motor FFI de Rust
  await RustLib.init();
  runApp(const ProviderScope(child: NcodeApp()));
}

// Proveedores de estado
final currentPathProvider = StateProvider<String>((ref) => '/home');
final selectedFileContentProvider = StateProvider<String>(
  (ref) => '// Selecciona un archivo para editar',
);
final selectedFilePathProvider = StateProvider<String?>((ref) => null);

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

class NcodeEditorScreen extends ConsumerWidget {
  const NcodeEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = ref.watch(currentPathProvider);
    final fileContent = ref.watch(selectedFileContentProvider);
    final activeFile = ref.watch(selectedFilePathProvider);

    return Scaffold(
      body: Row(
        children: [
          // 1. Panel Lateral: Explorador de Archivos
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
                // Header del Explorador
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: NexoraColors.border, width: 1),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Árbol de archivos (Procesado mediante el motor en Rust)
                Expanded(
                  child: FutureBuilder<List<FileEntry>>(
                    future: Future.value(readDirectory(dirPath: currentPath)),
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
                                fontSize: 13,
                              ),
                            ),
                            onTap: () {
                              if (item.isDir) {
                                ref.read(currentPathProvider.notifier).state =
                                    item.path;
                              } else {
                                ref
                                        .read(selectedFilePathProvider.notifier)
                                        .state =
                                    item.path;
                                final content = readFileContent(
                                  filePath: item.path,
                                );
                                ref
                                        .read(
                                          selectedFileContentProvider.notifier,
                                        )
                                        .state =
                                    "content";
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

          // 2. Editor de Código Principal
          Expanded(
            child: Column(
              children: [
                // Barra de pestañas superior
                Container(
                  height: 40,
                  width: double.infinity,
                  color: NexoraColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    activeFile ?? 'Sin archivo abierto',
                    style: const TextStyle(
                      color: NexoraColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const Divider(height: 1, color: NexoraColors.border),
                // Área de edición de texto
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: NexoraColors.background,
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: TextEditingController(text: fileContent),
                        maxLines: null,
                        style: const TextStyle(
                          color: NexoraColors.textPrimary,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
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
    );
  }
}
