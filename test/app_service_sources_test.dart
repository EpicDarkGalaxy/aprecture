import 'dart:convert';
import 'dart:io';

import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/services/download_service.dart';
import 'package:aprecture/services/providers/apkmirror_provider.dart';
import 'package:aprecture/services/providers/app_source.dart';
import 'package:aprecture/services/providers/izzy_on_droid_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class FakeSource extends AppSource {
  FakeSource(this._payload, {this.name = 'fake'});

  final Map<String, dynamic> _payload;
  final String name;

  @override
  String get sourceName => name;

  @override
  Future<Map<String, dynamic>> fetchApps() async => _payload;
}

class FakeIzzyHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final payload = {
      'packages': {
        'com.example.demo': {
          'metadata': {
            'name': {'en-US': 'Demo App'},
            'summary': {'en-US': 'A demo app'},
            'description': {'en-US': 'A longer description'},
            'authorName': 'Demo Dev',
            'sourceCode': 'https://example.com/source',
            'issueTracker': 'https://example.com/issues',
            'webSite': 'https://example.com',
            'categories': ['Tools'],
            'icon': {'en-US': {'name': '/icon.png'}},
            'screenshots': {
              'phone': {
                'en-US': [
                  {'name': '/screen.png'},
                ]
              }
            }
          },
          'versions': {
            'abc123': {
              'manifest': {'versionName': '1.2.3'}
            }
          }
        },
      }
    };

    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(payload))),
      200,
    );
  }
}

void main() {
  group('AppService source abstraction', () {
    test('merges apps from multiple sources without losing unique packages', () async {
      final sourceA = FakeSource({
        'com.example.alpha': {
          'name': 'Alpha',
          'summary': 'Alpha app',
          'description': 'Alpha desc',
          'iconUrl': '',
          'categories': ['Tools'],
          'screenshots': [],
          'author': 'A',
          'sourceCode': '',
          'issueTracker': '',
          'webSite': '',
        },
      });

      final sourceB = FakeSource({
        'com.example.beta': {
          'name': 'Beta',
          'summary': 'Beta app',
          'description': 'Beta desc',
          'iconUrl': '',
          'categories': ['Games'],
          'screenshots': [],
          'author': 'B',
          'sourceCode': '',
          'issueTracker': '',
          'webSite': '',
        },
      });

      final service = AppService.withSources([sourceA, sourceB]);
      final merged = await service.fetchAppsFromSources();

      expect(merged.keys, containsAll(['com.example.alpha', 'com.example.beta']));
      expect(merged.length, 2);
    });

    test('supports explicit opt-in providers without changing the default safe set', () async {
      final service = AppService.withConfiguredSources(
        sources: [
          FakeSource({
            'com.example.alpha': {
              'name': 'Alpha',
              'summary': 'Alpha app',
              'description': 'Alpha desc',
              'iconUrl': '',
              'categories': ['Tools'],
              'screenshots': [],
              'author': 'A',
              'sourceCode': '',
              'issueTracker': '',
              'webSite': '',
            },
          })
        ],
        optInSources: [ApkMirrorProvider()],
      );

      final merged = await service.fetchAppsFromSources();

      expect(merged.keys, contains('com.example.alpha'));
      expect(merged, isNotEmpty);
    });

    test('reads a valid F-Droid JSON index from the IzzyOnDroid repo', () async {
      final provider = IzzyOnDroidProvider(httpClient: FakeIzzyHttpClient());
      final data = await provider.fetchApps();

      expect(data, isNotEmpty);
      expect(data.keys, contains('com.example.demo'));
      expect(data['com.example.demo']['name'], 'Demo App');
      expect(data['com.example.demo']['versionName'], '1.2.3');
    });

    test('builds a concrete install URL for the Get action', () {
      final app = App.fromJson(
        packageName: 'org.fdroid.fdroid',
        json: {
          'name': 'F-Droid',
          'summary': 'F-Droid app',
          'description': 'desc',
          'iconUrl': '',
          'categories': ['Tools'],
          'screenshots': [],
          'author': 'F-Droid',
          'sourceCode': '',
          'issueTracker': '',
          'webSite': '',
          'sourceName': 'F-Droid',
        },
      );

      final uri = app.installUri;

      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(uri.host, 'f-droid.org');
      expect(uri.path, '/packages/org.fdroid.fdroid/');
    });

    test('treats a package page as an invalid APK download URL', () {
      final app = App.fromJson(
        packageName: 'ai.agent1c.hitomi.open',
        json: {
          'name': 'Hitomi',
          'summary': 'A demo app',
          'description': 'desc',
          'iconUrl': '',
          'categories': ['Tools'],
          'screenshots': [],
          'author': 'Hitomi',
          'sourceCode': '',
          'issueTracker': '',
          'webSite': '',
          'apkDownloadUrl': 'https://f-droid.org/packages/ai.agent1c.hitomi.open/',
          'sourceName': 'F-Droid',
        },
      );

      expect(app.downloadUri, isNull);
      expect(app.installUri, isNotNull);
    });

    test('marks the app as downloading before the HTTP response settles', () async {
      final client = DelayedDownloadHttpClient();
      final service = DownloadService(httpClient: client);

      final future = service.downloadApp('https://example.com/demo.apk', 'com.example.demo');

      expect(service.isDownloading('com.example.demo'), isTrue);

      final savedPath = await future;
      expect(savedPath, isNotNull);
      expect(service.isDownloading('com.example.demo'), isFalse);
    });

    test('downloads an APK payload to a writable file', () async {
      final client = FakeDownloadHttpClient();
      final service = DownloadService(httpClient: client);

      final savedPath = await service.downloadApp('https://example.com/demo.apk');

      expect(savedPath, isNotNull);
      expect(File(savedPath!).existsSync(), isTrue);
      expect(File(savedPath).readAsBytesSync(), equals([1, 2, 3, 4]));
    });
  });
}

class DelayedDownloadHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return http.StreamedResponse(
      Stream.value([1, 2, 3, 4]),
      200,
      request: request,
    );
  }
}

class FakeDownloadHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final payload = [1, 2, 3, 4];
    return http.StreamedResponse(
      Stream.value(payload),
      200,
      request: request,
    );
  }
}
