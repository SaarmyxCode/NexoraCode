import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/core/utils/system_path.dart';
import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/rust/api/file_system.dart';

class FileExplorer extends ConsumerStatefulWidget {
  final Function(String path, String name) onFileSelected;

  const FileExplorer({super.key, required this.onFileSelected});

  @override
  ConsumerState<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends ConsumerState<FileExplorer> {
  FileEntry? _focusedItem;

  void _refresh() {
    ref.read(fileExplorerRefreshProvider.notifier).state++;
  }

  Future<void> _pickNativeFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
      ref.read(currentPathProvider.notifier).setPath(selectedDirectory);
    }
  }

  void _showCreateFileDialog(String currentPath) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NexoraColors.surface,
        title: const Text(
          'Nuevo Archivo',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: NexoraColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'nombre_archivo.ext',
            hintStyle: TextStyle(color: NexoraColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: NexoraColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: NexoraColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: NexoraColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final newFilePath = '$currentPath/${controller.text.trim()}';
                final success = await FileService.createFile(newFilePath);
                if (context.mounted) Navigator.pop(context);
                if (success) _refresh();
              }
            },
            child: const Text(
              'Crear',
              style: TextStyle(color: NexoraColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(FileEntry item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NexoraColors.surface,
        title: const Text(
          'Renombrar',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: NexoraColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: NexoraColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: NexoraColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: NexoraColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != item.name) {
                final parent = SystemPath.getParent(item.path) ?? '';
                final newPath = '$parent/$newName';
                final success = await FileService.renameItem(
                  item.path,
                  newPath,
                );
                if (context.mounted) Navigator.pop(context);
                if (success) _refresh();
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: NexoraColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(FileEntry item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NexoraColors.surface,
        title: const Text(
          'Confirmar Eliminación',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: Text(
          '¿Deseas eliminar "${item.name}" definitivamente?',
          style: const TextStyle(
            color: NexoraColors.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: NexoraColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              final success = await FileService.deleteItem(item.path);
              if (context.mounted) Navigator.pop(context);
              if (success) {
                setState(() => _focusedItem = null);
                _refresh();
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: NexoraColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(currentPathProvider);
    final tabs = ref.watch(openTabsProvider);
    final activeIndex = ref.watch(activeTabIndexProvider);
    final dirAsync = ref.watch(directoryContentsProvider(currentPath));

    final rootFolderName = currentPath
        .split('/')
        .where((s) => s.isNotEmpty)
        .last;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && _focusedItem != null) {
          if (event.logicalKey == LogicalKeyboardKey.f2) {
            _showRenameDialog(_focusedItem!);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.delete) {
            _showDeleteConfirmDialog(_focusedItem!);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        width: 240,
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
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: NexoraColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: NexoraColors.accent,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'EXPLORADOR',
                    style: TextStyle(
                      color: NexoraColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  // Abrir Carpeta Nativa
                  IconButton(
                    icon: const Icon(
                      Icons.folder_open_rounded,
                      size: 14,
                      color: NexoraColors.textSecondary,
                    ),
                    tooltip: 'Abrir Carpeta (Nativo)',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _pickNativeFolder,
                  ),
                  const SizedBox(width: 8),
                  // Nuevo Archivo
                  IconButton(
                    icon: const Icon(
                      Icons.note_add_outlined,
                      size: 14,
                      color: NexoraColors.textSecondary,
                    ),
                    tooltip: 'Nuevo Archivo',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showCreateFileDialog(currentPath),
                  ),
                  const SizedBox(width: 8),
                  // Refrescar
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: NexoraColors.textSecondary,
                    ),
                    tooltip: 'Refrescar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _refresh,
                  ),
                ],
              ),
            ),
            // Nombre de la Carpeta Raíz Fija
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_special,
                    size: 13,
                    color: NexoraColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rootFolderName.toUpperCase(),
                      style: const TextStyle(
                        color: NexoraColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 8, color: NexoraColors.border),
            // Árbol de archivos
            Expanded(
              child: dirAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(
                      fontSize: 11,
                      color: NexoraColors.error,
                    ),
                  ),
                ),
                data: (items) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected =
                          activeIndex != null &&
                          activeIndex < tabs.length &&
                          tabs[activeIndex].path == item.path;
                      final isFocused = _focusedItem?.path == item.path;

                      return InkWell(
                        onTap: () {
                          setState(() => _focusedItem = item);
                          if (item.isDir) {
                            ref
                                .read(currentPathProvider.notifier)
                                .setPath(item.path);
                          } else {
                            widget.onFileSelected(item.path, item.name);
                          }
                        },
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          color: isFocused
                              ? NexoraColors.selection
                              : isSelected
                              ? NexoraColors.surfaceElevated
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Icon(
                                item.isDir
                                    ? Icons.folder_outlined
                                    : Icons.description_outlined,
                                size: 14,
                                color: item.isDir
                                    ? NexoraColors.accent
                                    : NexoraColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: isSelected || isFocused
                                        ? NexoraColors.textPrimary
                                        : NexoraColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: isSelected || isFocused
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
