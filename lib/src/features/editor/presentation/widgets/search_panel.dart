import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/features/editor/presentation/providers/editor_providers.dart';
import 'package:ncode/src/rust/api/search.dart';

class SearchPanel extends ConsumerStatefulWidget {
  final Function(String path, String name) onFileSelected;

  const SearchPanel({super.key, required this.onFileSelected});

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  bool _showReplace = false;

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    final currentPath = ref.read(currentPathProvider);
    setState(() => _isSearching = true);

    final results = await searchInWorkspace(
      rootPath: currentPath,
      query: query,
    );

    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  void _handleReplaceAll() async {
    final query = _searchController.text;
    final replacement = _replaceController.text;

    if (query.trim().isEmpty) return;

    final currentPath = ref.read(currentPathProvider);
    setState(() => _isSearching = true);

    final count = await replaceInWorkspace(
      rootPath: currentPath,
      query: query,
      replacement: replacement,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reemplazado "$query" por "$replacement" en $count archivos',
          ),
          backgroundColor: NexoraColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );

      _onSearchChanged(query);
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NexoraColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'BUSCAR',
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
                    _showReplace
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.find_replace_rounded,
                    size: 14,
                    color: NexoraColors.textSecondary,
                  ),
                  tooltip: _showReplace
                      ? 'Ocultar Reemplazar'
                      : 'Mostrar Reemplazar',
                  onPressed: () => setState(() => _showReplace = !_showReplace),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
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
                if (_showReplace) ...[
                  const SizedBox(height: 6),
                  TextField(
                    controller: _replaceController,
                    style: TextStyle(
                      color: NexoraColors.textPrimary,
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Reemplazar...',
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
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NexoraColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: _handleReplaceAll,
                      child: Text(
                        'Reemplazar Todo',
                        style: TextStyle(
                          color: NexoraColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: NexoraColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              'RESULTADOS (${_results.length})',
              style: TextStyle(
                color: NexoraColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : _results.isEmpty
                ? Center(
                    child: Text(
                      'Sin coincidencia',
                      style: TextStyle(
                        color: NexoraColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      final fileName = item.filePath.split('/').last;

                      return InkWell(
                        onTap: () {
                          widget.onFileSelected(item.filePath, fileName);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    fileName,
                                    style: TextStyle(
                                      color: NexoraColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ln ${item.lineNumber}',
                                    style: TextStyle(
                                      color: NexoraColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.lineText,
                                style: TextStyle(
                                  color: NexoraColors.textSecondary,
                                  fontSize: 11,
                                  fontFamily: 'Cascadia Code',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
