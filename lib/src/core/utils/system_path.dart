class SystemPath {
  static String? getParent(String path) {
    if (path == '/' || path.isEmpty) return null;
    final parts = path.split('/');
    parts.removeLast();
    if (parts.isEmpty || (parts.length == 1 && parts[0].isEmpty)) return '/';
    return parts.join('/');
  }
}
