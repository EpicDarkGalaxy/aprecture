import 'package:flutter/material.dart';
import 'package:aprecture/services/app_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appService = AppService();

  Future<void> _clearCache() async {
    await _appService.clearCache();
  }

  Future<void> _refreshIndex() async {
    await _appService.refreshIndex();
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
              onPressed: () async {
                await _clearCache();
              },
              child: const Text('Clear Cache'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _refreshIndex();
              },
              child: const Text('Referesh Index'),
            ),
          ],
        ),
      ),
    );
  }
}
