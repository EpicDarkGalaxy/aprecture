import 'dart:convert';
import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/app_providers/app_source_abstract.dart';
import 'package:aprecture/utils/utils.dart';
import 'package:http/http.dart' as http;

class FdroidProvider extends AppSource {
  final http.Client _httpClient = http.Client();

  @override
  String get sourceName => 'F-Droid';

  static const String _repoBaseUrl = 'https://f-droid.org/repo';

  /// Retrieves the localized value for a given key from the metadata,
  /// e.g. {'name': {'en-US': 'App Name'}}.
  /// If the key is not found, it returns an empty string.
  String _getLocalized(String key, Map<String, dynamic> metadata) {
    final localized = metadata[key];
    if (localized is Map<String, dynamic>) {
      // F-Droid uses 'en-US' with a hyphen!
      final value = localized['en-US'] ?? localized.values.firstOrNull;
      return value is String ? value : '';
    }
    return localized?.toString() ?? '';
  }

  // Icon in v2 is an object: {en-US: {name: "/pkg/icon.png", sha256: ..., size: ...}}
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

  // versionName lives in versions -> <hash> -> manifest -> versionName
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
          // Look for en-US or fallback to first available locale
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
    return [];
  }

  @override
  Future<Map<String, dynamic>> fetchApps() async {
    try {
      logger.d('Fetching apps from F-Droid...');

      final response = await _httpClient.get(
        Uri.parse('https://f-droid.org/repo/index-v2.json'),
      );

      logger.d('Response CODE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Format data before writing to cache
        final rawPackages = data['packages'] as Map<String, dynamic>;
        final Map<String, dynamic> formattedData = {};

        for (final package in rawPackages.entries) {
          final packageName = package.key;
          final pkgData = package.value;
          final metadata = pkgData['metadata'] as Map<String, dynamic>;

          final name = _getLocalized('name', metadata);
          final versionName = _getVersionName(pkgData);
          final summary = _getLocalized('summary', metadata);
          final description = cleanHtml(_getLocalized('description', metadata));
          final categories = (metadata['categories'] as List?) ?? [];
          final iconUrl = _getIconUrl(metadata);
          final screenshots = _getScreenshots(metadata);
          final author =
              metadata["authorName"]?.toString() ?? 'Unknown Developer';
          final sourceCode = metadata['sourceCode']?.toString() ?? '';
          final issueTracker = metadata['issueTracker']?.toString() ?? '';
          final webSite = metadata['webSite']?.toString() ?? '';
          final sourceName =
              this.sourceName; // Add the source name to the sources list

          String apkDownloadUrl = '';
          final versions = pkgData['versions'];
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
          formattedData[packageName] = formatAppData(
            name: name,
            packageName: packageName,
            versionName: versionName,
            summary: summary,
            description: description,
            categories: categories.cast<String>(),
            iconUrl: iconUrl,
            screenshots: screenshots,
            author: author,
            sourceCode: sourceCode,
            issueTracker: issueTracker,
            webSite: webSite,
            sourceName: sourceName,
            apkDownloadUrl: apkDownloadUrl,
          );
        }
        return formattedData;
      } else {
        logger.e('Failed to fetch apps from F-Droid: ${response.statusCode}');
        return {};
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching apps from F-Droid: $e', stackTrace: stackTrace);
      return {};
    }
  }
}
