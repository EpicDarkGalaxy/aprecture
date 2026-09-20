import 'package:flutter/material.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/services/providers/app_source.dart';
import 'package:aprecture/services/providers/providers_map.dart';

class OptInSourcesScreen extends StatefulWidget {
  const OptInSourcesScreen({super.key});

  @override
  State<OptInSourcesScreen> createState() => _OptInSourcesScreenState();
}

class _OptInSourcesScreenState extends State<OptInSourcesScreen> {
  final _appService = AppService();

  void _toggleOptInSource(AppSource source) {
    _appService.toggleOptInSource(source);
  }

  @override
  Widget build(BuildContext context) {
    final optInSources = providersMap['Opt-In']!.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opt-In Sources'),
      ),
      body: ListenableBuilder(
        listenable: _appService,
        builder: (context, _) {
          return ListView.builder(
            itemCount: optInSources.length,
            itemBuilder: (context, index) {
              final source = optInSources[index];
              final isEnabled = _appService.optInSources.contains(source);

              return SwitchListTile(
                title: Text(source.sourceName),
                value: isEnabled,
                onChanged: (value) {
                  _toggleOptInSource(source);
                },
              );
            },
          );
        },
      )
    );
  }
}