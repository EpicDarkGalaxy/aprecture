class App {
  final String appId; // Unique identifier for the app
  final String name; // Display name of the app, e.g., "F-Droid"
  final String
  packageName; // Unique package name of the app, e.g., "org.fdroid.fdroid"
  final String versionName; // Version name of the app, e.g., "1.0.0"
  final String summary; // Short summary or description of the app
  final String description; // Description of the app
  final String iconUrl; // URL to the app's icon
  final List<String> categories; // List of categories the app belongs to
  final List<String> screenshots;
  final String author; // Developer name
  final String sourceCode; // URL to the source code repository
  final String issueTracker; // URL to the issue tracker
  final String webSite; // URL to the app's website
  final Map<String, String> sourceNames =
      <
        String,
        String
      >{}; // List of sources where the app is available and their URLs

  App({
    required this.appId,
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
    required String apkDownloadUrl,
    required String sourceName,
  }) {
    sourceNames[sourceName] = apkDownloadUrl;
  }

  String downloadUrl(String sourceName) {
    return sourceNames[sourceName] ?? '';
  }

  factory App.fromJson({
    required String appId,
    required String packageName,
    required Map<String, dynamic> json,
  }) {
    return App(
      appId: appId,
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
      apkDownloadUrl: json['apkDownloadUrl'] ?? '',
      sourceName: json['sourceName'] ?? 'Unknown Source',
    );
  }
}
