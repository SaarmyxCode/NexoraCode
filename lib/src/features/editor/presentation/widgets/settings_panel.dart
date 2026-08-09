import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ncode/src/core/theme/theme_provider.dart';
import 'package:ncode/src/features/editor/presentation/widgets/nexora_floating_card.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(activePaletteProvider);
    final currentMode = ref.watch(themeModeProvider);

    return NexoraFloatingCard(
      width: 250,
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: palette.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, size: 16, color: palette.accent),
                const SizedBox(width: 8),
                Text(
                  'TEMAS Y ESTÉTICA',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(
                  'APARIENCIA BASE',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  ref,
                  'Modo Oscuro',
                  NexoraThemeMode.dark,
                  currentMode == NexoraThemeMode.dark,
                  palette,
                ),
                _buildThemeOption(
                  ref,
                  'Modo Claro',
                  NexoraThemeMode.light,
                  currentMode == NexoraThemeMode.light,
                  palette,
                ),
                const SizedBox(height: 16),
                Text(
                  'SUITE NEXORA',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  ref,
                  'Nexora Rename',
                  NexoraThemeMode.rename,
                  currentMode == NexoraThemeMode.rename,
                  palette,
                ),
                _buildThemeOption(
                  ref,
                  'Nexora Drive',
                  NexoraThemeMode.drive,
                  currentMode == NexoraThemeMode.drive,
                  palette,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    WidgetRef ref,
    String title,
    NexoraThemeMode mode,
    bool isSelected,
    NexoraThemePalette palette,
  ) {
    return InkWell(
      onTap: () => ref.read(themeModeProvider.notifier).state = mode,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? palette.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: palette.accent, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 14, color: palette.accent),
          ],
        ),
      ),
    );
  }
}
