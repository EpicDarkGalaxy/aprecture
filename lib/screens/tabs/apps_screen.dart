import 'package:flutter/material.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/screens/app_details_screen.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/widgets/skeletons/app_list_skeleton.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  final _appService = AppService();

  @override
  void initState() {
    super.initState();
    _appService.refreshApps(); // Refresh apps when the screen is first loaded with cached data if available, otherwise fetch from F-Droid
  }

  /// Group apps by their first category
  Map<String, List<App>> _groupByCategory(List<App> apps) {
    final Map<String, List<App>> grouped = {};
    for (final app in apps) {
      final category = app.categories.isNotEmpty ? app.categories.first : 'Other';
      grouped.putIfAbsent(category, () => []).add(app);
    }
    return grouped;
  }

  void _openApp(App app) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppDetailsScreen(app: app)),
    );
  }

  /// One app card inside a horizontal carousel
  Widget _appCard(App app) {
    return SizedBox(
      width: 110,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openApp(app),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(app.iconUrl, errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.android);
                  }), // Fallback to default icon
                ),
              ),
              const SizedBox(height: 8),
              Text(
                app.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A titled section with a horizontal carousel
  Widget _categorySection(String title, List<App> apps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: apps.length,
            itemBuilder: (context, index) => _appCard(apps[index]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apps")),
      body: ListenableBuilder(
        listenable: _appService,
        builder: (context, snapshot) {
          if (_appService.isLoading) {
            return ListView.builder(itemBuilder: (context, index) {
              if (index % 2 == 0) {
                return const AppListSkeleton();
              } else {
                return const SizedBox(height: 16);
              }
            });
          } else if (_appService.apps.isEmpty) {
            return SizedBox(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "Failed to load apps. \nPlease check your internet connection or try refreshing.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _appService.refreshIndex,
                      child: const Text("Refresh"),
                    ),
                  ],
                ),
              ),
            );
          }

          final grouped = _groupByCategory(_appService.apps);
          final categories = grouped.keys.toList()..sort();
          return RefreshIndicator(
              onRefresh: _appService.refreshIndex, // on pull down, force refresh apps
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _categorySection(category, grouped[category]!);
                },
              ),
            );
        },
      ),
    );
  }
}
