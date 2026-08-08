import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class StatusBar extends StatelessWidget {
  final String? activeFilePath;
  final int line;
  final int column;
  final int errorCount;
  final int warningCount;
  final VoidCallback onToggleTerminal;

  const StatusBar({
    super.key,
    this.activeFilePath,
    this.line = 1,
    this.column = 1,
    this.errorCount = 0,
    this.warningCount = 0,
    required this.onToggleTerminal,
  });

  @override
  Widget build(BuildContext context) {
    final language = _getLanguageName(activeFilePath);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: NexoraColors.surface,
        border: Border(top: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.alt_route_rounded,
            size: 12,
            color: NexoraColors.accent,
          ),
          const SizedBox(width: 6),
          const Text(
            'main',
            style: TextStyle(color: NexoraColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(width: 14),
          Icon(
            Icons.cancel_outlined,
            size: 12,
            color: errorCount > 0 ? NexoraColors.error : NexoraColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '$errorCount',
            style: TextStyle(
              color: errorCount > 0
                  ? NexoraColors.error
                  : NexoraColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: warningCount > 0 ? Colors.orange : NexoraColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '$warningCount',
            style: TextStyle(
              color: warningCount > 0 ? Colors.orange : NexoraColors.textMuted,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Text(
            'Ln $line, Col $column',
            style: const TextStyle(
              color: NexoraColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            language,
            style: const TextStyle(
              color: NexoraColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          InkWell(
            onTap: onToggleTerminal,
            child: const Row(
              children: [
                Icon(
                  Icons.terminal_rounded,
                  size: 12,
                  color: NexoraColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  'Terminal',
                  style: TextStyle(
                    color: NexoraColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String? path) {
    if (path == null) return 'Plain Text';
    if (path.endsWith('.dart')) return 'Dart';
    if (path.endsWith('.rs')) return 'Rust';
    if (path.endsWith('.json')) return 'JSON';
    if (path.endsWith('.js')) return 'JavaScript';
    if (path.endsWith('.ts')) return 'TypeScript';
    if (path.endsWith('.py')) return 'Python';
    return 'Plain Text';
  }
}
