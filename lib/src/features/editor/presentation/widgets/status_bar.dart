import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/rust/api/git.dart';

class StatusBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = ref.watch(currentPathProvider);
    final language = _getLanguageName(activeFilePath);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        border: Border(top: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.alt_route_rounded, size: 12, color: NexoraColors.accent),
          const SizedBox(width: 6),
          FutureBuilder<String>(
            future: getGitBranch(repoPath: currentPath),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? '...',
                style: TextStyle(
                  color: NexoraColors.textSecondary,
                  fontSize: 11,
                ),
              );
            },
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
            style: TextStyle(color: NexoraColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(width: 14),
          Text(
            language,
            style: TextStyle(
              color: NexoraColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          InkWell(
            onTap: onToggleTerminal,
            child: Row(
              children: [
                Icon(
                  Icons.terminal_rounded,
                  size: 12,
                  color: NexoraColors.textSecondary,
                ),
                const SizedBox(width: 4),
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
    if (path == null || path.isEmpty) return 'Plain Text';

    final p = path.toLowerCase();

    if (p.endsWith('.dart')) return 'Dart';
    if (p.endsWith('.rs')) return 'Rust';
    if (p.endsWith('.jsx')) return 'React JSX';
    if (p.endsWith('.tsx')) return 'React TSX';
    if (p.endsWith('.js')) return 'JavaScript';
    if (p.endsWith('.ts')) return 'TypeScript';
    if (p.endsWith('.json')) return 'JSON';
    if (p.endsWith('.py')) return 'Python';
    if (p.endsWith('.html') || p.endsWith('.htm')) return 'HTML';
    if (p.endsWith('.css')) return 'CSS';

    return 'Plain Text';
  }
}
