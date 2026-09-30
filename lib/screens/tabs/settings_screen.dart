import 'package:aprecture/services/theme/app_theme_service.dart';
import 'package:flutter/material.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprecture/screens/opt_in_sources_screen.dart';
import 'package:aprecture/services/logger.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AppThemeMode _selectedTheme;

  Future<void> _clearCache() async =>
      ref.read(appServiceProvider.notifier).clearCache();

  Future<void> _refreshIndex() async =>
      ref.read(appServiceProvider.notifier).refreshIndex();

  void _toggleTheme(AppThemeMode theme) {
    final notifier = ref.read(appThemeServiceProvider.notifier);
    notifier.setTheme(theme);
    logger.d('Theme toggled to $theme');
  }

  void _optInSources() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OptInSourcesScreen()),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Theme'),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    ListTile(
                      title: const Text('Light'),
                      onTap: () {
                        _toggleTheme(AppThemeMode.light);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Dark'),
                      onTap: () {
                        _toggleTheme(AppThemeMode.dark);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        ListTile(title: const Text('Clear Cache'), onTap: () => _clearCache()),
        ListTile(
          title: const Text('Refresh Index'),
          onTap: () => _refreshIndex(),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      children: [
        ListTile(title: const Text('Opt In Sources'), onTap: _optInSources),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedTheme = ref.watch(appThemeServiceProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Material(
            color:
                colorScheme.surfaceContainerLow, // Material 3 surface container
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              splashColor: colorScheme.primary.withAlpha(25),
              highlightColor: colorScheme.primary.withAlpha(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.secondaryContainer),
                ),
                child: Column(
                  children: [
                    _buildGeneralSettings(),
                    const SizedBox(height: 16),
                    Divider(color: theme.dividerColor),
                    _buildAdvancedSettings(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
