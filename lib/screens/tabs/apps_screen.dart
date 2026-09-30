import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprecture/widgets/apps_list_item.dart';
import 'package:aprecture/widgets/hero_app_card.dart';
import 'package:aprecture/models/app.dart';
import 'package:go_router/go_router.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/widgets/skeletons/apps_screen_skeleton.dart';
import 'package:aprecture/services/logger.dart';

// Helper sealed class to represent item types in the flattened list
sealed class AppListItemType {}

class CategoryHeaderItem extends AppListItemType {
  final String title;
  final int count;
  CategoryHeaderItem(this.title, this.count);
}

class SingleAppItem extends AppListItemType {
  final App app;
  SingleAppItem(this.app);
}

class AppsScreen extends ConsumerStatefulWidget {
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appServiceProvider.notifier).refreshApps();
    });
  }

  void _openApp(App app) {
    context.push('/app-details/${app.appId}');
  }

  Widget _buildHeroSection(List<App> randomApps) {
    if (randomApps.isEmpty) {
      logger.d('Random apps is empty');
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Random Apps',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: randomApps.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final app = randomApps[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: HeroAppCard(app: app, onTap: () => _openApp(app)),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(appServiceProvider).isLoading;
    final randomApps = ref.watch(appServiceProvider).randomApps;
    final groupedApps = ref.watch(appServiceProvider).groupedApps;
    final categories = ref.watch(appServiceProvider).categories;

    if (isLoading) return const AppsScreenSkeleton();

    if (groupedApps.isEmpty) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(appServiceProvider.notifier).refreshApps();
          },
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Failed to load apps. \nPlease check your internet connection or try refreshing.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(appServiceProvider.notifier).refreshApps(),
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 1. Flatten categories into a single indexable list for TRUE lazy loading
    final List<AppListItemType> flattenedItems = [];
    for (final category in categories) {
      final apps = groupedApps[category] ?? [];
      if (apps.isNotEmpty) {
        flattenedItems.add(CategoryHeaderItem(category, apps.length));
        for (final app in apps) {
          flattenedItems.add(SingleAppItem(app));
        }
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(appServiceProvider.notifier).refreshApps();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // 2. Hero Section
            SliverToBoxAdapter(child: _buildHeroSection(randomApps)),

            // 3. Fully lazy-rendered items with dynamic extents per item type
            SliverVariedExtentList.builder(
              itemCount: flattenedItems.length,
              itemExtentBuilder: (index, dimensions) {
                final item = flattenedItems[index];
                if (item is CategoryHeaderItem) {
                  return 52.0; // Header height
                }
                return 130.0; // AppsListItem height
              },
              itemBuilder: (context, index) {
                final item = flattenedItems[index];

                if (item is CategoryHeaderItem) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${item.count} apps",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (item is SingleAppItem) {
                  return AppsListItem(
                    app: item.app,
                    onTap: () => _openApp(item.app),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
