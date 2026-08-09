import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ncode/src/core/theme/theme_provider.dart';
import 'package:ncode/src/features/editor/presentation/widgets/nexora_floating_card.dart';

class ActivityBar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const ActivityBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(activePaletteProvider);

    return NexoraFloatingCard(
      width: 50,
      margin: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            isSelected: selectedIndex == 0,
            onTap: () => onSelect(0),
            palette: palette,
          ),
          _NavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            isSelected: selectedIndex == 1,
            onTap: () => onSelect(1),
            palette: palette,
          ),
          _NavItem(
            icon: Icons.alt_route_rounded,
            activeIcon: Icons.alt_route_rounded,
            isSelected: selectedIndex == 2,
            onTap: () => onSelect(2),
            palette: palette,
          ),
          _NavItem(
            icon: Icons.bug_report_outlined,
            activeIcon: Icons.bug_report,
            isSelected: selectedIndex == 3,
            onTap: () => onSelect(3),
            palette: palette,
          ),
          _NavItem(
            icon: Icons.extension_outlined,
            activeIcon: Icons.extension,
            isSelected: selectedIndex == 4,
            onTap: () => onSelect(4),
            palette: palette,
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            isSelected: selectedIndex == 5,
            onTap: () => onSelect(5),
            palette: palette,
          ),
          _NavItem(
            icon: Icons.palette_outlined,
            activeIcon: Icons.palette,
            isSelected: selectedIndex == 6,
            onTap: () => onSelect(6),
            palette: palette,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final NexoraThemePalette palette;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        width: 42,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? palette.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 20,
          color: isSelected ? palette.accent : palette.textMuted,
        ),
      ),
    );
  }
}
