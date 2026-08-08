import 'package:ncode/src/rust/api/file_system.dart';

class FileService {
  static Future<List<FileEntry>> getDirectoryEntries(String path) async {
    return await readDirectory(dirPath: path);
  }

  static Future<String> getFileContent(String path) async {
    return await readFileContent(filePath: path);
  }

  static Future<bool> saveFileContent(String path, String content) async {
    return await writeFileContent(filePath: path, content: content);
  }
}
