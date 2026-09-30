import 'package:flutter/material.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprecture/services/app_providers/providers_map.dart';

class OptInSourcesScreen extends ConsumerStatefulWidget {
  const OptInSourcesScreen({super.key});

  @override
  ConsumerState<OptInSourcesScreen> createState() => _OptInSourcesScreenState();
}

class _OptInSourcesScreenState extends ConsumerState<OptInSourcesScreen> {
  @override
  Widget build(BuildContext context) {
    final appService = ref.watch(appServiceProvider);
    final optInSources = providersMap['Opt-In']!.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Opt-In Sources')),
      body: ListView.builder(
        itemCount: optInSources.length,
        itemBuilder: (context, index) {
          final source = optInSources[index];
          final isEnabled = appService.optInSources.contains(source);

          return SwitchListTile(
            title: Text(source.sourceName),
            value: isEnabled,
            onChanged: (value) {
              ref.read(appServiceProvider.notifier).toggleOptInSource(source);
            },
          );
        },
      ),
    );
  }
}
