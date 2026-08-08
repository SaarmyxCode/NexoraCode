import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/rust/api/git.dart';

class GitPanel extends ConsumerStatefulWidget {
  const GitPanel({super.key});

  @override
  ConsumerState<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends ConsumerState<GitPanel> {
  final TextEditingController _commitController = TextEditingController();
  List<GitFileChange> _changes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final currentPath = ref.read(currentPathProvider);
    setState(() => _isLoading = true);
    final changes = await getGitStatus(repoPath: currentPath);
    if (mounted) {
      setState(() {
        _changes = changes;
        _isLoading = false;
      });
    }
  }

  void _handleCommit() async {
    final msg = _commitController.text.trim();
    if (msg.isEmpty) return;

    final currentPath = ref.read(currentPathProvider);
    setState(() => _isLoading = true);

    final success = await gitCommit(repoPath: currentPath, message: msg);
    if (mounted) {
      if (success) {
        _commitController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Commit realizado con éxito'),
            backgroundColor: NexoraColors.surfaceElevated,
            duration: const Duration(milliseconds: 600),
          ),
        );
        _fetchStatus();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        border: Border(right: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NexoraColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alt_route_rounded,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'CONTROL DE VERSIONES',
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: NexoraColors.textSecondary,
                  ),
                  tooltip: 'Refrescar Git',
                  onPressed: _fetchStatus,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _commitController,
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Mensaje de commit...',
                    hintStyle: TextStyle(
                      color: NexoraColors.textMuted,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: NexoraColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: NexoraColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: NexoraColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexoraColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleCommit,
                    child: Text(
                      'Commit',
                      style: TextStyle(
                        color: NexoraColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: NexoraColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              'CAMBIOS (${_changes.length})',
              style: TextStyle(
                color: NexoraColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : _changes.isEmpty
                ? Center(
                    child: Text(
                      'Repositorio Limpio',
                      style: TextStyle(
                        color: NexoraColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _changes.length,
                    itemBuilder: (context, index) {
                      final change = _changes[index];
                      return Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                change.path,
                                style: TextStyle(
                                  color: NexoraColors.textSecondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              change.status,
                              style: TextStyle(
                                color: change.status == 'M'
                                    ? Colors.orange
                                    : change.status == 'A' ||
                                          change.status == '??'
                                    ? Colors.green
                                    : NexoraColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
