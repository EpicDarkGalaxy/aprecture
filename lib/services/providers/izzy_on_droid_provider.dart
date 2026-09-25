import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/providers/app_source.dart';

class IzzyOnDroidProvider extends AppSource {
  IzzyOnDroidProvider({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  String get sourceName => 'IzzyOnDroid';

  static const String _fingerprint =
      '3BF0D6ABFEAE2F401707B6D966BE743BF0EEE49C2561B9BA39073711F628937A';
  static const String _repoBaseUrl = 'https://apt.izzysoft.de/fdroid/repo';
  static const String _indexUrl = '$_repoBaseUrl/index-v2.json?fingerprint=$_fingerprint';

  String _getLocalized(String key, Map<String, dynamic> metadata) {
    final localized = metadata[key];
    if (localized is Map<String, dynamic>) {
      final value = localized['en-US'] ?? localized.values.firstOrNull;
      return value is String ? value : '';
    }
    return localized?.toString() ?? '';
  }

  String _getIconUrl(Map<String, dynamic> metadata) {
    final icon = metadata['icon'];
    if (icon is Map<String, dynamic>) {
      final localizedIcon = icon['en-US'] ?? icon.values.firstOrNull;
      if (localizedIcon is Map && localizedIcon['name'] is String) {
        return '$_repoBaseUrl${localizedIcon['name']}';
      }
    }
    return '';
  }

  String _getVersionName(dynamic pkgData) {
    final versions = pkgData['versions'];
    if (versions is Map && versions.isNotEmpty) {
      final firstVersion = versions.values.first;
      if (firstVersion is Map) {
        final manifest = firstVersion['manifest'];
        if (manifest is Map) {
          return manifest['versionName']?.toString() ?? '';
        }
      }
    }
    return '';
  }

  List<String> _getScreenshots(Map<String, dynamic> metadata) {
    try {
      final screenshotsMap = metadata['screenshots'];
      if (screenshotsMap is Map) {
        final phoneMap = screenshotsMap['phone'];
        if (phoneMap is Map) {
          final localeList = phoneMap['en-US'] ?? phoneMap.values.firstOrNull;
          if (localeList is List) {
            return localeList
                .map((item) => item is Map ? item['name']?.toString() : null)
                .where((name) => name != null && name.isNotEmpty)
                .map((name) => '$_repoBaseUrl$name')
                .toList()
                .cast<String>();
          }
        }
      }
    } catch (_) {}
    return const [];
  }

  String _cleanHtml(String htmlString) {
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

  @override
  Future<Map<String, dynamic>> fetchApps() async {
    try {
      logger.d('Fetching apps from IzzyOnDroid...');
      final response = await _httpClient.get(Uri.parse(_indexUrl));

      logger.d('Response CODE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawPackages = data['packages'];
        final formattedData = <String, dynamic>{};

        if (rawPackages is! Map) {
          logger.e('Unexpected package index format from IzzyOnDroid');
          return {};
        }

        for (final package in rawPackages.entries) {
          final packageName = package.key.toString();
          final pkgData = package.value;
          if (pkgData is! Map) continue;
          final metadataMap = pkgData['metadata'];
          if (metadataMap is! Map) continue;

          final metadata = Map<String, dynamic>.from(metadataMap);
          final pkg = Map<String, dynamic>.from(pkgData);

          String apkDownloadUrl = '';
          final versions = pkg['versions'];
          if (versions is Map) {
            for (final versionEntry in versions.values) {
              if (versionEntry is Map && versionEntry['file'] is Map) {
                final fileName = versionEntry['file']['name']?.toString();
                if (fileName != null && fileName.isNotEmpty) {
                  apkDownloadUrl = '$_repoBaseUrl$fileName';
                  break;
                }
              }
            }
          }

          formattedData[packageName] = {
            'name': _getLocalized('name', metadata),
            'versionName': _getVersionName(pkg),
            'summary': _cleanHtml(_getLocalized('summary', metadata)),
            'description': _cleanHtml(_getLocalized('description', metadata)),
            'categories': (metadata['categories'] as List?) ?? const [],
            'iconUrl': _getIconUrl(metadata),
            'screenshots': _getScreenshots(metadata),
            'author': metadata['authorName']?.toString() ?? 'Unknown Developer',
            'sourceCode': metadata['sourceCode']?.toString() ?? '',
            'issueTracker': metadata['issueTracker']?.toString() ?? '',
            'webSite': metadata['webSite']?.toString() ?? '',
            'apkDownloadUrl': apkDownloadUrl,
            'sourceName': sourceName,
          };
        }

        logger.d('Parsed ${formattedData.length} apps from IzzyOnDroid');
        return formattedData;
      }

      logger.e('Failed to fetch apps from IzzyOnDroid. Status code: ${response.statusCode}');
      return {};
    } catch (e, stackTrace) {
      logger.e('Error fetching apps from IzzyOnDroid: $e', stackTrace: stackTrace);
      return {};
    }
  }
}