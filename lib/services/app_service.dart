import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/app_providers/providers_map.dart';
import 'package:aprecture/services/app_providers/app_source_abstract.dart';
import 'package:aprecture/services/download_service.dart';
import 'package:aprecture/services/app_sub_services//package_events.dart';
import 'package:aprecture/utils/utils.dart' as utils;

part 'app_service.g.dart';

class AppServiceState {
  final List<App> apps;
  final List<PackageEvent> packageEvents;
  final List<App> searchedApps;
  final List<App> randomApps;
  final Map<String, List<App>> groupedApps;
  final List<String> categories;
  final bool isLoading;
  final List<AppSource> sources;
  final List<AppSource> optInSources;

  AppServiceState({
    required this.apps,
    required this.packageEvents,
    required this.searchedApps,
    required this.randomApps,
    required this.groupedApps,
    required this.categories,
    required this.isLoading,
    required this.sources,
    required this.optInSources,
  });

  AppServiceState copyWith({
    List<App>? apps,
    List<PackageEvent>? packageEvents,
    List<App>? searchedApps,
    List<App>? randomApps,
    Map<String, List<App>>? groupedApps,
    List<String>? categories,
    bool? isLoading,
    List<AppSource>? sources,
    List<AppSource>? optInSources,
  }) {
    return AppServiceState(
      apps: apps ?? this.apps,
      packageEvents: packageEvents ?? this.packageEvents,
      searchedApps: searchedApps ?? this.searchedApps,
      randomApps: randomApps ?? this.randomApps,
      groupedApps: groupedApps ?? this.groupedApps,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      sources: sources ?? this.sources,
      optInSources: optInSources ?? this.optInSources,
    );
  }
}

@riverpod
Future<bool> isAppInstalled(Ref ref, String packageName) async {
  final appState = ref.watch(appServiceProvider);

  // Check recent live events first (latest event takes priority)
  final event = appState.packageEvents
      .where((e) => e.packageName == packageName)
      .lastOrNull;

  if (event != null) {
    return event.eventType == "installed";
  }

  // Fall back to initial/cached installed apps list if no event exists
  return await InstalledApps.isAppInstalled(packageName) ?? false;
}

@riverpod
class AppService extends _$AppService {
  late final File _cacheFile;
  late final List<AppSource> _sources;
  List<AppSource> _optInSources = [];
  late final PackageEvents _packageEvents;

  @override
  AppServiceState build() {
    _cacheFile = File("${Directory.systemTemp.path}/apps_cache.json");
    _sources = providersMap['Default']?.values.toList() ?? [];
    _packageEvents = PackageEvents();
    _packageEvents.startListening(onPackageEvent);

    ref.onDispose(() {
      _packageEvents.stopListening();
    });

    return AppServiceState(
      apps: [],
      packageEvents: [],
      searchedApps: [],
      randomApps: [],
      groupedApps: {},
      categories: [],
      isLoading: false,
      sources: _sources,
      optInSources: _optInSources,
    );
  }

  void _updateState({
    List<App>? apps,
    List<PackageEvent>? packageEvents,
    List<App>? searchedApps,
    List<App>? randomApps,
    Map<String, List<App>>? groupedApps,
    List<String>? categories,
    bool? isLoading,
    List<AppSource>? sources,
    List<AppSource>? optInSources,
  }) {
    if (!ref.mounted) return;

    state = state.copyWith(
      apps: apps,
      packageEvents: packageEvents,
      searchedApps: searchedApps,
      randomApps: randomApps,
      groupedApps: groupedApps,
      categories: categories,
      isLoading: isLoading,
      sources: sources,
      optInSources: optInSources,
    );
  }

  void onPackageEvent(PackageEvent event) {
    _updateState(packageEvents: [...state.packageEvents, event]);
  }

  void toggleOptInSource(AppSource source) {
    final updated = List<AppSource>.from(_optInSources);
    if (updated.contains(source)) {
      updated.remove(source);
    } else {
      updated.add(source);
    }
    _optInSources = updated;
    _updateState(optInSources: _optInSources);
  }

  Future<void> clearCache() async {
    if (await _cacheFile.exists()) {
      await _cacheFile.delete();
      logger.i("Cache cleared");
    }
  }

  Future<void> refreshIndex() async {
    await clearCache();
    await refreshApps();
    logger.i("Index refreshed");
  }

  Future<void> writeAppsToCache(Map<String, dynamic> apps) async {
    final json = jsonEncode(apps);
    await _cacheFile.writeAsString(json);
  }

  App getApp(String appId) {
    return state.apps.firstWhere((app) => app.appId == appId);
  }

  Future<void> installApp(String appPath, String packageName) async {
    if (!Platform.isAndroid) {
      logger.w('installApp is only supported on Android');
      return;
    }

    final result = await OpenFilex.open(appPath);
    if (result.type != ResultType.done) {
      logger.e('Failed to install app: ${result.message}');
      return;
    }
    logger.i('App installed successfully');
  }

  Future<bool> openApp(String packageName) async {
    return await InstalledApps.startApp(packageName) ?? false;
  }

  Future<List<App>> getRandomApps(List<App> apps) async {
    if (apps.isEmpty) return [];

    final maxCount = 5;
    final newRandomApps = <App>[];

    for (var i = 0; i < maxCount; i++) {
      final app = apps[Random().nextInt(apps.length)];
      if (app.iconUrl.isNotEmpty) {
        newRandomApps.add(app);
      }
    }
    return newRandomApps;
  }

  static Future<List<App>> _parsePackages(String packagesJsonString) async {
    final Map<String, dynamic> packages = jsonDecode(packagesJsonString);
    final List<App> apps = [];
    for (final package in packages.entries) {
      final app = App.fromJson(
        appId: package
            .key, // Right now, Using Package Name as App ID. Will change to a unique Number per package
        packageName: package.key,
        json: package.value,
      );
      apps.add(app);
    }
    return apps;
  }

  /// Group apps by their first category
  static Map<String, List<App>> _groupByCategory(List<App> apps) {
    final Map<String, List<App>> grouped = {};
    for (final app in apps) {
      final category = app.categories.isNotEmpty
          ? app.categories.first
          : 'Other';
      grouped.putIfAbsent(category, () => []).add(app);
    }
    return grouped;
  }

  Future<void> refreshApps() async {
    _updateState(isLoading: true);
    String packagesJsonString = '';
    try {
      if (await _cacheFile.exists() && await _cacheFile.length() > 0) {
        packagesJsonString = await _cacheFile.readAsString();
        logger.d('Loaded apps from cache');
      } else {
        final appsMap = await fetchAppsFromSources();
        if (appsMap.isEmpty) {
          logger.e('No apps fetched from configured sources');
          _updateState(isLoading: false);
          return;
        }
        await writeAppsToCache(appsMap);
        packagesJsonString = jsonEncode(appsMap);
        logger.d('Fetched apps from configured sources and cached them');
      }

      final List<App> parsedApps = await Isolate.run(
        () => _parsePackages(packagesJsonString),
      );

      final Map<String, List<App>> groupedApps = await Isolate.run(
        () => _groupByCategory(parsedApps),
      );
      final List<String> categories = groupedApps.keys.toList()..sort();

      final List<App> randomApps = await getRandomApps(parsedApps);

      _updateState(
        isLoading: false,
        apps: parsedApps,
        groupedApps: groupedApps,
        categories: categories,
        randomApps: randomApps,
      );
    } catch (e) {
      logger.e('Error while refreshing apps: $e');
      _updateState(isLoading: false);
    }
  }

  Future<Map<String, dynamic>> fetchAppsFromSources() async {
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

  List<App> searchApps(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase().trim();
    final terms = q.split(RegExp(r'\s+'));
    return state.apps.where((app) {
      final name = app.name.toLowerCase();
      final summary = app.summary.toLowerCase();
      final categories = app.categories.join(' ').toLowerCase();

      return terms.every((term) {
        if (name.contains(term) ||
            summary.contains(term) ||
            categories.contains(term)) {
          return true;
        }
        return utils.fuzzyMatch(name, term, 0.8);
      });
    }).toList();
  }
}
