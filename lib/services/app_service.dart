import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/providers/fdroid_provider.dart';
import 'package:aprecture/utils/utils.dart' as utils;

class AppService extends ChangeNotifier {
  AppService._internal();
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;

  final FdroidProvider _fdroidProvider = FdroidProvider();

  bool _isLoading = false;
  List<App> _apps = [];

  bool get isLoading => _isLoading;
  List<App> get apps => _apps;

  static File get cacheFile =>
      File("${Directory.systemTemp.path}/apps_cache.json");

  Future<void> clearCache() async {
    if (await cacheFile.exists()) {
      await cacheFile.delete();
      logger.i("Cache cleared");
    }
  }

  Future<void> refreshIndex() async {
    _apps.clear();
    await clearCache();
    await refreshApps();
    logger.i("Index refreshed");
  }

  Future<void> writeAppsToCache(Map<String, dynamic> apps) async {
    final json = jsonEncode(apps);
    await cacheFile.writeAsString(json);
  }

  static List<App> _parsePackages(String packagesJsonString) {
    logger.d('Wrapping packages into a list of App objects...');
    final Map<String, dynamic> packages = jsonDecode(packagesJsonString);
    final List<App> apps = [];
    for (final package in packages.entries) {
      final app = App.fromJson(packageName: package.key, json: package.value);
      apps.add(app);
    }
    logger.d('Parsed ${apps.length} apps');
    return apps;
  }

  Future<void> refreshApps() async {
    _isLoading = true;
    notifyListeners();
    if (_apps.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (await cacheFile.exists()) {
      logger.i("Cache hit");
      final cachedApps = await cacheFile.readAsString();
      _apps = await Isolate.run(() => _parsePackages(cachedApps));
      logger.d('Loaded ${_apps.length} apps from cache');
      _isLoading = false;
      notifyListeners();
      return;
    }

    logger.i("Cache miss");
    final formattedApps = await _fdroidProvider.getApps();
    await writeAppsToCache(formattedApps);

    final formattedAppsJson = jsonEncode(formattedApps);
    _apps = await Isolate.run(() => _parsePackages(formattedAppsJson));
    _isLoading = false;
    notifyListeners();
  }

  List<App> searchApps(String query) {
    logger.d('Searching for apps with query: $query');
    if (query.isEmpty) return [];
    final q = query.toLowerCase().trim();
    final terms = q.split(RegExp(r'\s+'));
    final results = _apps.where((app) {
      final name = app.name.toLowerCase();
      final summary = app.summary.toLowerCase();
      final categories = app.categories.join(' ').toLowerCase();
      return terms.every((term) {
        if (name.contains(term) ||
            summary.contains(term) ||
            categories.contains(term)) {
          return true;
        }
        return utils.fuzzyMatch(name, term, 0.8) || // 80%
            utils.fuzzyMatch(summary, term, 0.6) || // 60%
            utils.fuzzyMatch(categories, term, 0.7); // 70%
      });
    }).toList();
    return results;
  }
}
