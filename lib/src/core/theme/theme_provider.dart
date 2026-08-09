import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nexora_ui/nexora_ui.dart';

enum NexoraThemeMode {
  dark,
  light,
  rename, // Paleta de Nexora Rename (Verde Esmeralda)
  drive, // Paleta de Nexora Drive (Azul Profundo)
}

class NexoraThemePalette {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color accent;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const NexoraThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.accent,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const dark = NexoraThemePalette(
    background: Color(0xFF0A0A0C),
    surface: Color(0xFF141417),
    surfaceElevated: Color(0xFF1C1C21),
    accent: Color(0xFFE11F2F),
    border: Color(0x1AFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFD2D2D7),
    textMuted: Color(0xFF6E6E73),
  );

  static const light = NexoraThemePalette(
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE8E8ED),
    accent: Color(0xFFE11F2F),
    border: Color(0x14000000),
    textPrimary: Color(0xFF1D1D1F),
    textSecondary: Color(0xFF424245),
    textMuted: Color(0xFF86868B),
  );

  static const rename = NexoraThemePalette(
    background: Color(0xFF08120E),
    surface: Color(0xFF0E1F18),
    surfaceElevated: Color(0xFF152E24),
    accent: Color(0xFF10B981),
    border: Color(0x2210B981),
    textPrimary: Color(0xFFECFDF5),
    textSecondary: Color(0xFFA7F3D0),
    textMuted: Color(0xFF047857),
  );

  static const drive = NexoraThemePalette(
    background: Color(0xFF070B14),
    surface: Color(0xFF0E1726),
    surfaceElevated: Color(0xFF17253D),
    accent: Color(0xFF3B82F6),
    border: Color(0x223B82F6),
    textPrimary: Color(0xFFEFF6FF),
    textSecondary: Color(0xFFBFDBFE),
    textMuted: Color(0xFF1D4ED8),
  );
}

final themeModeProvider = StateProvider<NexoraThemeMode>(
  (ref) => NexoraThemeMode.dark,
);

final activePaletteProvider = Provider<NexoraThemePalette>((ref) {
  final mode = ref.watch(themeModeProvider);
  switch (mode) {
    case NexoraThemeMode.dark:
      return NexoraThemePalette.dark;
    case NexoraThemeMode.light:
      return NexoraThemePalette.light;
    case NexoraThemeMode.rename:
      return NexoraThemePalette.rename;
    case NexoraThemeMode.drive:
      return NexoraThemePalette.drive;
  }
});
