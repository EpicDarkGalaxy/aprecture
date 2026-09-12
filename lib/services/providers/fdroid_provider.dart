import 'dart:convert';
import 'package:aprecture/services/logger.dart';
import 'package:http/http.dart' as http;

class FdroidProvider {
  final http.Client _httpClient = http.Client();

  static const String _repoBaseUrl = 'https://f-droid.org/repo';

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

  Future<Map<String, dynamic>> getApps() async {
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
          formattedData[packageName] = {
            'name': _getLocalized('name', metadata),
            'versionName': _getVersionName(pkgData),
            'summary': _cleanHtml(_getLocalized('summary', metadata)),
            'description': _cleanHtml(_getLocalized('description', metadata)),
            'categories': (metadata['categories'] as List?) ?? [],
            'iconUrl': _getIconUrl(metadata),
          };
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
