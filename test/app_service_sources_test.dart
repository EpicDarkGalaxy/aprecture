import 'dart:convert';

import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/app_service.dart';
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
  });
}
