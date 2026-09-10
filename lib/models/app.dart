class App {
  final String name;
  final String packageName;
  final String versionName;
  final String summary;
  final String description;
  final String iconUrl;

  App({
    required this.name,
    required this.packageName,
    required this.versionName,
    required this.summary,
    required this.description,
    required this.iconUrl,
  });

  factory App.fromJson({
    required String packageName,
    required Map<String, dynamic> json,
  }) {
    return App(
      name: json['name'] ?? 'NONAME',
      packageName: packageName,
      versionName: json['versionName'] ?? 'NOVERSION',
      summary: json['summary'] ?? 'NOSUMMARY',
      description: json['description'] ?? 'NODESCRIPTION',
      iconUrl: json['iconUrl'] ?? 'NOICON',
    );
  }
}
