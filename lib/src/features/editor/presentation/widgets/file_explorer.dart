import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/core/utils/system_path.dart';
import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/features/editor/presentation/widgets/file_tree_item.dart';
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
        title: Text(
          'Nuevo Archivo',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
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
            child: Text(
              'Cancelar',
              style: TextStyle(color: NexoraColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final targetPath = _focusedItem != null && _focusedItem!.isDir
                    ? _focusedItem!.path
                    : currentPath;
                final newFilePath = '$targetPath/${controller.text.trim()}';
                final success = await FileService.createFile(newFilePath);
                if (mounted) Navigator.pop(context);
                if (success) _refresh();
              }
            },
            child: Text('Crear', style: TextStyle(color: NexoraColors.accent)),
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
        title: Text(
          'Renombrar',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
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
            child: Text(
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
                if (mounted) Navigator.pop(context);
                if (success) _refresh();
              }
            },
            child: Text(
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
        title: Text(
          'Confirmar Eliminación',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: Text(
          '¿Deseas eliminar "${item.name}" definitivamente?',
          style: TextStyle(color: NexoraColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: NexoraColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              final success = await FileService.deleteItem(item.path);
              if (mounted) Navigator.pop(context);
              if (success) {
                setState(() => _focusedItem = null);
                _refresh();
              }
            },
            child: Text(
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
    final activeTab = (activeIndex != null && activeIndex < tabs.length)
        ? tabs[activeIndex]
        : null;
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
        decoration: BoxDecoration(
          color: NexoraColors.surface,
          border: Border(
            right: BorderSide(color: NexoraColors.border, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: NexoraColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: NexoraColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'EXPLORADOR',
                    style: TextStyle(
                      color: NexoraColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.folder_open_rounded,
                      size: 14,
                      color: NexoraColors.textSecondary,
                    ),
                    tooltip: 'Abrir Carpeta Raíz',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _pickNativeFolder,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
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
                  IconButton(
                    icon: Icon(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_special,
                    size: 13,
                    color: NexoraColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rootFolderName.toUpperCase(),
                      style: TextStyle(
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
            Divider(height: 8, color: NexoraColors.border),
            Expanded(
              child: dirAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: TextStyle(fontSize: 11, color: NexoraColors.error),
                  ),
                ),
                data: (items) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return FileTreeItem(
                        item: item,
                        level: 0,
                        focusedItem: _focusedItem,
                        activeFilePath: activeTab?.path,
                        onItemTap: (clickedItem) {
                          setState(() => _focusedItem = clickedItem);
                          if (!clickedItem.isDir) {
                            widget.onFileSelected(
                              clickedItem.path,
                              clickedItem.name,
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
    );
  }
}
