import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/rust/api/file_system.dart';

class FileTreeItem extends StatefulWidget {
  final FileEntry item;
  final int level;
  final FileEntry? focusedItem;
  final String? activeFilePath;
  final Function(FileEntry) onItemTap;

  const FileTreeItem({
    super.key,
    required this.item,
    this.level = 0,
    required this.focusedItem,
    required this.activeFilePath,
    required this.onItemTap,
  });

  @override
  State<FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<FileTreeItem> {
  bool _isExpanded = false;
  List<FileEntry> _children = [];
  bool _isLoading = false;

  Future<void> _toggleExpand() async {
    if (!widget.item.isDir) return;

    if (!_isExpanded && _children.isEmpty) {
      setState(() => _isLoading = true);
      final entries = await FileService.getDirectoryEntries(widget.item.path);
      if (mounted) {
        setState(() {
          _children = entries;
          _isLoading = false;
          _isExpanded = true;
        });
      }
    } else {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.activeFilePath == widget.item.path;
    final isFocused = widget.focusedItem?.path == widget.item.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            widget.onItemTap(widget.item);
            if (widget.item.isDir) {
              _toggleExpand();
            }
          },
          child: Container(
            height: 26,
            padding: EdgeInsets.only(
              left: 12.0 + (widget.level * 14.0),
              right: 12.0,
            ),
            color: isFocused
                ? NexoraColors.selection
                : isSelected
                ? NexoraColors.surfaceElevated
                : Colors.transparent,
            child: Row(
              children: [
                if (widget.item.isDir)
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 14,
                    color: NexoraColors.textMuted,
                  )
                else
                  const SizedBox(width: 14),
                const SizedBox(width: 4),
                Icon(
                  widget.item.isDir
                      ? (_isExpanded
                            ? Icons.folder_open_outlined
                            : Icons.folder_outlined)
                      : Icons.description_outlined,
                  size: 14,
                  color: widget.item.isDir
                      ? NexoraColors.accent
                      : NexoraColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: TextStyle(
                      color: isSelected || isFocused
                          ? NexoraColors.textPrimary
                          : NexoraColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: isSelected || isFocused
                          ? FontWeight.w500
                          : FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.2),
                  ),
              ],
            ),
          ),
        ),
        if (widget.item.isDir && _isExpanded)
          Column(
            children: _children
                .map(
                  (childItem) => FileTreeItem(
                    item: childItem,
                    level: widget.level + 1,
                    focusedItem: widget.focusedItem,
                    activeFilePath: widget.activeFilePath,
                    onItemTap: widget.onItemTap,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
