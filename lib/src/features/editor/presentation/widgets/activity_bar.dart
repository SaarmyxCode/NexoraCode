import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class ActivityBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const ActivityBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        border: Border(right: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _ActivityNavItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            isSelected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          _ActivityNavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            isSelected: selectedIndex == 1,
            onTap: () => onSelect(1),
          ),
          _ActivityNavItem(
            icon: Icons.alt_route_rounded,
            activeIcon: Icons.alt_route_rounded,
            isSelected: selectedIndex == 2,
            onTap: () => onSelect(2),
          ),
          _ActivityNavItem(
            icon: Icons.bug_report_outlined,
            activeIcon: Icons.bug_report,
            isSelected: selectedIndex == 3,
            onTap: () => onSelect(3),
          ),
          _ActivityNavItem(
            icon: Icons.extension_outlined,
            activeIcon: Icons.extension,
            isSelected: selectedIndex == 4,
            onTap: () => onSelect(4),
          ),
          const Spacer(),
          _ActivityNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            isSelected: selectedIndex == 5,
            onTap: () => onSelect(5),
          ),
          _ActivityNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            isSelected: selectedIndex == 6,
            onTap: () => onSelect(6),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActivityNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityNavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        width: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected
                  ? NexoraColors.textPrimary
                  : NexoraColors.textMuted,
            ),
            if (isSelected)
              Positioned(
                left: 0,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: NexoraColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
