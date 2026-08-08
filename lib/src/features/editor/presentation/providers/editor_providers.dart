import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ncode/src/features/editor/domain/tab_item.dart';
import 'package:ncode/src/features/editor/data/file_service.dart';
import 'package:ncode/src/rust/api/file_system.dart';

final currentPathProvider = StateProvider<String>((ref) => '/home');
final openTabsProvider = StateProvider<List<TabItem>>((ref) => []);
final activeTabIndexProvider = StateProvider<int?>((ref) => null);

final directoryContentsProvider =
    FutureProvider.family<List<FileEntry>, String>((ref, path) async {
      return await FileService.getDirectoryEntries(path);
    });
