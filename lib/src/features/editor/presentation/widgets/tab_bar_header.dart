import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';

class TabBarHeader extends ConsumerWidget {
  final VoidCallback onSave;
  final Function(int index) onCloseTab;
  final Function(int index) onTabSelected;

  const TabBarHeader({
    super.key,
    required this.onSave,
    required this.onCloseTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(openTabsProvider);
    final activeIndex = ref.watch(activeTabIndexProvider);

    return Container(
      height: 40,
      width: double.infinity,
      color: NexoraColors.surface,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = index == activeIndex;

                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? NexoraColors.background
                          : NexoraColors.surface,
                      border: Border(
                        right: const BorderSide(
                          color: NexoraColors.border,
                          width: 1,
                        ),
                        top: isActive
                            ? const BorderSide(
                                color: NexoraColors.accent,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          tab.name,
                          style: TextStyle(
                            color: isActive
                                ? NexoraColors.textPrimary
                                : NexoraColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (tab.isModified)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: NexoraColors.accent,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => onCloseTab(index),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: NexoraColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (activeIndex != null)
            IconButton(
              icon: const Icon(
                Icons.save_outlined,
                size: 15,
                color: NexoraColors.textSecondary,
              ),
              tooltip: 'Guardar (Ctrl+S)',
              onPressed: onSave,
            ),
        ],
      ),
    );
  }
}
