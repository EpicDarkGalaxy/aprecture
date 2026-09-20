import 'package:flutter/material.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/screens/opt_in_sources_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appService = AppService();

  // This does not refresh the app list, it only clears the cache of the app list.
  Future<void> _clearCache() async => _appService.clearCache(); 

  Future<void> _refreshIndex() async => _appService.refreshIndex(); // Clear cache and refresh app list.

  void _optInSources() {
    // Navigate to a new screen where the user can select opt-in sources
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OptInSourcesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child:Column(
          children: [
            ElevatedButton(
              onPressed: _clearCache,
              child: const Text('Clear Cache'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshIndex,
              child: const Text('Refresh Index'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _optInSources,
              child: const Text('Opt-In Sources'),
            ),
          ],
        ),
      ),
    );
  }
}
