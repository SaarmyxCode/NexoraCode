import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ncode/src/core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NexoraDropZone extends ConsumerStatefulWidget {
  final Widget child;
  final Function(List<XFile> files) onFilesDropped;

  const NexoraDropZone({
    super.key,
    required this.child,
    required this.onFilesDropped,
  });

  @override
  ConsumerState<NexoraDropZone> createState() => _NexoraDropZoneState();
}

class _NexoraDropZoneState extends ConsumerState<NexoraDropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(activePaletteProvider);

    return DropTarget(
      onDragEntered: (details) => setState(() => _isDragging = true),
      onDragExited: (details) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        if (details.files.isNotEmpty) {
          widget.onFilesDropped(details.files);
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDragging)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.12),
                  border: Border.all(color: palette.accent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          color: palette.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Soltar archivo para abrir en Ncode',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
