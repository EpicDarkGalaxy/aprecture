class App {
  final String name;
  final String packageName;
  final String versionName;
  final String summary;
  final String description;
  final String iconUrl;
  final List<String> categories;
  final List<String> screenshots;
  final String author;
  final String sourceCode;
  final String issueTracker;
  final String webSite;

  App({
    required this.name,
    required this.packageName,
    required this.versionName,
    required this.summary,
    required this.description,
    required this.iconUrl,
    required this.categories,
    required this.screenshots,
    required this.author,
    required this.sourceCode,
    required this.issueTracker,
    required this.webSite,
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
      categories: (json['categories'] as List?)?.cast<String>() ?? const [],
      screenshots: (json['screenshots'] as List?)?.cast<String>() ?? const [],
      author: json['author'] ?? 'Unknown Developer',
      sourceCode: json['sourceCode'] ?? '',
      issueTracker: json['issueTracker'] ?? '',
      webSite: json['webSite'] ?? '',
    );
  }
}
