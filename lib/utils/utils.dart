bool fuzzyMatch(String text, String pattern, double threshold) {
  if (pattern.isEmpty) return true;
  if (text.isEmpty) return false;

  // Simple sliding window or word-level similarity check,
  // or checking chunks of the text against the pattern.
  final words = text.split(RegExp(r'\s+'));
  for (final word in words) {
    if (similarity(word, pattern) >= threshold) {
      return true;
    }
  }
  // Also check substrings if pattern is long enough
  for (int i = 0; i <= text.length - pattern.length; i++) {
    final sub = text.substring(i, i + pattern.length);
    if (similarity(sub, pattern) >= threshold) {
      return true;
    }
  }
  return false;
}

double similarity(String s1, String s2) {
  if (s1 == s2) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  int matches = 0;
  final length = s1.length > s2.length ? s1.length : s2.length;
  for (int i = 0; i < (s1.length < s2.length ? s1.length : s2.length); i++) {
    if (s1[i] == s2[i]) matches++;
  }
  return matches / length;
}

Map<String, dynamic> formatAppData({
  String name = 'Unknown',
  String packageName = 'Unknown',
  String versionName = 'Unknown',
  String author = 'Unknown',
  String description = 'No description',
  String summary = '',
  String iconUrl = '',
  String sourceCode = '',
  String issueTracker = '',
  String sourceName = '',
  String webSite = '',
  String apkDownloadUrl = '',
  List<String> categories = const [],
  List<String> screenshots = const [],
}) {
  final safeName = name.trim().isEmpty ? 'Unknown' : name.trim();
  final safePackageName = packageName.trim().isEmpty
      ? 'Unknown'
      : packageName.trim();
  final safeVersionName = versionName.trim().isEmpty
      ? 'Unknown'
      : versionName.trim();

  final normalizedAuthor = author.trim().isEmpty
      ? 'Unknown'
      : (Uri.tryParse(author.trim()) != null &&
                author.trim().startsWith(
                  RegExp(r'https?://', caseSensitive: false),
                )
            ? 'Active Developer'
            : author.trim());

  return {
    'name': safeName,
    'packageName': safePackageName,
    'categories': categories,
    'author': normalizedAuthor,
    'description': description.trim().isEmpty ? 'No description' : description,
    'summary': summary,
    'iconUrl': iconUrl,
    'versionName': safeVersionName,
    'screenshots': screenshots,
    'sourceCode': sourceCode,
    'issueTracker': issueTracker,
    'sourceName': sourceName,
    'webSite': webSite,
    'apkDownloadUrl': apkDownloadUrl,
  };
}

String cleanHtml(String htmlString) {
  if (htmlString.isEmpty) return '';
  final stripped = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  return stripped
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .trim();
}
