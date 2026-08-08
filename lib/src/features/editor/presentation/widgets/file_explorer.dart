import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/core/utils/system_path.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';

class FileExplorer extends ConsumerWidget {
  final Function(String path, String name) onFileSelected;

  const FileExplorer({super.key, required this.onFileSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = ref.watch(currentPathProvider);
    final tabs = ref.watch(openTabsProvider);
    final activeIndex = ref.watch(activeTabIndexProvider);
    final dirAsync = ref.watch(directoryContentsProvider(currentPath));

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: NexoraColors.surface,
        border: Border(right: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                const SizedBox(width: 8),
                const Text(
                  'NCODE',
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    final parent = SystemPath.getParent(currentPath);
                    if (parent != null) {
                      ref.read(currentPathProvider.notifier).state = parent;
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 14,
                      color: NexoraColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(
              currentPath.toUpperCase(),
              style: const TextStyle(
                color: NexoraColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected =
                        activeIndex != null &&
                        activeIndex < tabs.length &&
                        tabs[activeIndex].path == item.path;

                    return InkWell(
                      onTap: () {
                        if (item.isDir) {
                          ref.read(currentPathProvider.notifier).state =
                              item.path;
                        } else {
                          onFileSelected(item.path, item.name);
                        }
                      },
                      child: Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        color: isSelected
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
                                  color: isSelected
                                      ? NexoraColors.textPrimary
                                      : NexoraColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected
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
    );
  }
}
