import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ncode/src/features/editor/domain/tab_item.dart';
import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/rust/api/file_system.dart';

const String _kLastOpenFolderKey = 'last_open_folder';

// Notifier para administrar la ruta activa y guardarla localmente
class CurrentPathNotifier extends StateNotifier<String> {
  CurrentPathNotifier() : super('/home') {
    _loadSavedPath();
  }

  Future<void> _loadSavedPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_kLastOpenFolderKey);
    if (savedPath != null && savedPath.isNotEmpty) {
      state = savedPath;
    }
  }

  Future<void> setPath(String newPath) async {
    state = newPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastOpenFolderKey, newPath);
  }
}

final currentPathProvider = StateNotifierProvider<CurrentPathNotifier, String>((
  ref,
) {
  return CurrentPathNotifier();
});

final openTabsProvider = StateProvider<List<TabItem>>((ref) => []);
final activeTabIndexProvider = StateProvider<int?>((ref) => null);

// Proveedor para controlar la versión/refresco del árbol de archivos
final fileExplorerRefreshProvider = StateProvider<int>((ref) => 0);

final directoryContentsProvider =
    FutureProvider.family<List<FileEntry>, String>((ref, path) async {
      ref.watch(
        fileExplorerRefreshProvider,
      ); // Se invalida cuando cambia este contador
      return await FileService.getDirectoryEntries(path);
    });
