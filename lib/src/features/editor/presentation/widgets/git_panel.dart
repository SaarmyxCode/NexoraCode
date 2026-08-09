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
  List<String> _branches = [];
  String _currentBranch = 'main';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshGit();
  }

  Future<void> _refreshGit() async {
    final currentPath = ref.read(currentPathProvider);
    setState(() => _isLoading = true);

    final branch = await getGitBranch(repoPath: currentPath);
    final branches = await getGitBranches(repoPath: currentPath);
    final changes = await getGitStatus(repoPath: currentPath);

    if (mounted) {
      setState(() {
        _currentBranch = branch;
        _branches = branches;
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
        _showMessage('Commit realizado con éxito');
        _refreshGit();
      } else {
        _showMessage('Error al realizar commit');
        setState(() => _isLoading = false);
      }
    }
  }

  void _handlePush() async {
    final currentPath = ref.read(currentPathProvider);
    setState(() => _isLoading = true);

    final result = await gitPush(repoPath: currentPath);
    if (mounted) {
      if (result == 'OK') {
        _showMessage('Desplegado / Pushed a GitHub con éxito');
      } else {
        _showMessage('Respuesta: $result');
      }
      _refreshGit();
    }
  }

  void _handlePull() async {
    final currentPath = ref.read(currentPathProvider);
    setState(() => _isLoading = true);

    final result = await gitPull(repoPath: currentPath);
    if (mounted) {
      if (result == 'OK') {
        _showMessage('Cambios sincronizados desde GitHub');
      } else {
        _showMessage('Pull status: $result');
      }
      _refreshGit();
    }
  }

  void _showCreateBranchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NexoraColors.surface,
        title: Text(
          'Nueva Rama',
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 14),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: NexoraColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'nombre-de-la-rama',
            hintStyle: TextStyle(color: NexoraColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: NexoraColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: NexoraColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: NexoraColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newBranch = controller.text.trim();
              if (newBranch.isNotEmpty) {
                final currentPath = ref.read(currentPathProvider);
                final ok = await createGitBranch(
                  repoPath: currentPath,
                  newBranchName: newBranch,
                );
                if (mounted) Navigator.pop(context);
                if (ok) _refreshGit();
              }
            },
            child: Text('Crear', style: TextStyle(color: NexoraColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: NexoraColors.surfaceElevated,
        duration: const Duration(seconds: 2),
      ),
    );
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
          // Header
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                const SizedBox(width: 6),
                Text(
                  'GIT & GITHUB',
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
                    Icons.cloud_download_outlined,
                    size: 14,
                    color: NexoraColors.textSecondary,
                  ),
                  tooltip: 'Git Pull (GitHub)',
                  onPressed: _handlePull,
                ),
                IconButton(
                  icon: Icon(
                    Icons.cloud_upload_outlined,
                    size: 14,
                    color: NexoraColors.textSecondary,
                  ),
                  tooltip: 'Git Push (GitHub)',
                  onPressed: _handlePush,
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: NexoraColors.textSecondary,
                  ),
                  tooltip: 'Refrescar',
                  onPressed: _refreshGit,
                ),
              ],
            ),
          ),

          // Selector de Rama y Nueva Rama
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.call_split_rounded,
                      size: 14,
                      color: NexoraColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'RAMA ACTIVA',
                      style: TextStyle(
                        color: NexoraColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _showCreateBranchDialog,
                      child: Text(
                        '+ Nueva',
                        style: TextStyle(
                          color: NexoraColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: NexoraColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: NexoraColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _branches.contains(_currentBranch)
                          ? _currentBranch
                          : null,
                      hint: Text(
                        _currentBranch,
                        style: TextStyle(
                          color: NexoraColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                      isExpanded: true,
                      dropdownColor: NexoraColors.surfaceElevated,
                      style: TextStyle(
                        color: NexoraColors.textPrimary,
                        fontSize: 12,
                      ),
                      items: _branches.map((b) {
                        return DropdownMenuItem<String>(
                          value: b,
                          child: Text(
                            b,
                            style: TextStyle(
                              color: NexoraColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newBranch) async {
                        if (newBranch != null && newBranch != _currentBranch) {
                          final currentPath = ref.read(currentPathProvider);
                          final ok = await checkoutGitBranch(
                            repoPath: currentPath,
                            branchName: newBranch,
                          );
                          if (ok) _refreshGit();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: NexoraColors.border),

          // Input de Commit y Botones
          Padding(
            padding: const EdgeInsets.all(10),
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
                    enabledBorder: OutlineInputBorder(
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
                Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 6),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: NexoraColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: Icon(
                        Icons.upload_rounded,
                        size: 16,
                        color: NexoraColors.accent,
                      ),
                      tooltip: 'Push a GitHub',
                      onPressed: _isLoading ? null : _handlePush,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: NexoraColors.border),

          // Lista de Cambios
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              'CAMBIOS SIN GUARDAR (${_changes.length})',
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
                      return InkWell(
                        onTap: () async {
                          final currentPath = ref.read(currentPathProvider);
                          final ok = await gitStageFile(
                            repoPath: currentPath,
                            filePath: change.path,
                          );
                          if (ok) _refreshGit();
                        },
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  change.path,
                                  style: TextStyle(
                                    color: NexoraColors.textSecondary,
                                    fontSize: 11,
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
