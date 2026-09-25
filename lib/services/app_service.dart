import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/providers/providers_map.dart';
import 'package:aprecture/services/providers/app_source.dart';
import 'package:aprecture/utils/utils.dart' as utils;

class AppService extends ChangeNotifier {
  AppService._internal([
    List<AppSource>? sources,
    List<AppSource>? optInSources,
  ]) : _sources = sources ?? const <AppSource>[],
       _optInSources = optInSources ?? const <AppSource>[];

  static final AppService _instance = AppService._internal([
    ...providersMap['Default']!.values,
  ], []);
  factory AppService() => _instance;

  factory AppService.withConfiguredSources({
    List<AppSource>? sources,
    List<AppSource>? optInSources,
  }) {
    final safeSources = (sources ?? [...providersMap['Default']!.values])
        .where((source) => !source.isOptIn)
        .toList();
    final enabledOptIn = (optInSources ?? const <AppSource>[])
        .where((source) => source.isOptIn)
        .toList();

    return AppService._internal(safeSources, enabledOptIn);
  }

  factory AppService.withSources(List<AppSource> sources) {
    return AppService.withConfiguredSources(sources: sources);
  }

  factory AppService.withOptInSources(List<AppSource> optInSources) {
    return AppService.withConfiguredSources(
      sources: [...providersMap['Default']!.values],
      optInSources: optInSources,
    );
  }

  final List<AppSource> _sources; // List of sources for the app service
  final List<AppSource>
  _optInSources; // List of opt-in sources for the app service

  bool _isLoading = false; // Whether the app service is currently loading apps
  List<App> _apps = [];

  bool get isLoading => _isLoading;
  List<App> get apps => _apps;

  List<AppSource> get optInSources => _instance._optInSources;

  static File get cacheFile =>
      File("${Directory.systemTemp.path}/apps_cache.json");

  void toggleOptInSource(AppSource source) {
    if (_optInSources.contains(source)) {
      _optInSources.remove(source);
    } else {
      _optInSources.add(source);
    }
    notifyListeners();
  }

  Future<void> clearCache() async {
    if (await cacheFile.exists()) {
      await cacheFile.delete();
      logger.i("Cache cleared");
    }
  }

  Future<void> refreshIndex() async {
    _apps
        .clear(); // Clear the current list of apps to avoid showing stale data while refreshing and duplicates after refresh
    await clearCache(); // Clear the cache to force a fresh fetch from F-Droid
    await refreshApps();
    logger.i("Index refreshed");
  }

  Future<void> writeAppsToCache(Map<String, dynamic> apps) async {
    final json = jsonEncode(apps);
    await cacheFile.writeAsString(json);
  }

  Future<bool> isAppInstalled(String packageName) async {
    return await InstalledApps.isAppInstalled(packageName) ?? false;
  }

  Future<void> installApp(String appPath) async {
    final result = await OpenFilex.open(appPath);
    if (result.type != ResultType.done) {
      logger.e('Failed to install app: ${result.message}');
      return;
    }
    logger.i('App installed successfully');
  }

  // Future<void> uninstallApp(String packageName) async {
  //   final result = await OpenFilex.open('package:$packageName');
  //   if (result.type != ResultType.done) {
  //     logger.e('Failed to uninstall app: ${result.message}');
  //     return;
  //   }
  //   logger.i('App uninstalled successfully');
  // }

  Future<bool> openApp(String packageName) async {
    return await InstalledApps.startApp(packageName) ?? false;
  }

  static List<App> _parsePackages(String packagesJsonString) {
    // Convert the JSON string to a map and then to a list of App objects
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

  Future<Map<String, dynamic>> fetchAppsFromSources() async {
    // Fetch apps from all sources and merge them into a single map
    final merged = <String, dynamic>{};
    final sources = <AppSource>[..._sources, ..._optInSources];

    for (final source in sources) {
      final data = await source.fetchApps();
      for (final entry in data.entries) {
        merged.putIfAbsent(entry.key, () => entry.value);
      }
    }

    return merged;
  }

  Future<void> refreshApps() async {
    // Refresh apps by fetching from sources and caching the result
    _isLoading = true;
    notifyListeners();

    String packagesJsonString = '';
    try {
      if (await cacheFile.exists() && await cacheFile.length() > 0) {
        packagesJsonString = await cacheFile.readAsString();
        logger.d('Loaded apps from cache');
      } else {
        final appsMap = await fetchAppsFromSources();
        if (appsMap.isEmpty) {
          logger.e('No apps fetched from configured sources');
          _isLoading = false;
          notifyListeners();
          return;
        }
        await writeAppsToCache(appsMap);
        packagesJsonString = jsonEncode(appsMap);
        logger.d('Fetched apps from configured sources and cached them');
      }

      final List<App> parsedApps = await Isolate.run(
        () => _parsePackages(packagesJsonString),
      );
      _apps = parsedApps;
    } catch (e) {
      logger.e('Error while refreshing apps: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        return utils.fuzzyMatch(name, term, 0.8); // 60%
        // utils.fuzzyMatch(summary, term, 0.6) || // 40%
        // utils.fuzzyMatch(categories, term, 0.7); // 30%
      });
    }).toList();
    return results;
  }
}
