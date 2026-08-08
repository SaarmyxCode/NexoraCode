class TabItem {
  final String path;
  final String name;
  String content;
  bool isModified;

  TabItem({
    required this.path,
    required this.name,
    required this.content,
    this.isModified = false,
  });
}
