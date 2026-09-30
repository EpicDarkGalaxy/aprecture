import 'package:flutter/material.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/services/download_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetButton extends ConsumerStatefulWidget {
  const GetButton({
    super.key,
    required this.name,
    required this.packageName,
    required this.downloadUrl,
  });

  final String name;
  final String packageName;
  final String downloadUrl;

  @override
  ConsumerState<GetButton> createState() => _GetButtonState();
}

class _GetButtonState extends ConsumerState<GetButton> {
  @override
  Widget build(BuildContext context) {
    final appService = ref.watch(appServiceProvider.notifier);
    final isInstalled = ref.watch(isAppInstalledProvider(widget.packageName));
    final isDownloading = ref.watch(isDownloadingProvider(widget.packageName));
    final downloadProgress = ref.watch(
      downloadProgressProvider(widget.packageName),
    );
    final isLoading = ref.watch(isLoadingProvider(widget.packageName));
    final isCompleted = ref.watch(isCompletedProvider(widget.packageName));

    final filePath = ref.watch(
      downloadServiceProvider.select((s) => s[widget.packageName]?.filePath),
    );

    return SizedBox(
      width: 80,
      height: 36,
      child: _buildContent(
        context: context,
        isInstalled: isInstalled.value ?? false,
        isDownloading: isDownloading,
        isLoading: isLoading,
        isCompleted: isCompleted,
        downloadProgress: downloadProgress,
        filePath: filePath,
        appService: appService,
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isInstalled,
    required bool isDownloading,
    required bool isLoading,
    required bool isCompleted,
    required double downloadProgress,
    required String? filePath,
    required dynamic appService,
  }) {
    if (isInstalled) {
      return ElevatedButton(
        onPressed: () => appService.openApp(widget.packageName),
        child: const Text("Open"),
      );
    }

    if (isDownloading) {
      if (isLoading) {
        return const Center(child: LinearProgressIndicator());
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: downloadProgress > 0 ? downloadProgress : null,
              strokeWidth: 3,
            ),
          ),
          Text(
            "${(downloadProgress * 100).round()}%",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (isCompleted) {
      return ElevatedButton(
        onPressed: () {
          if (filePath != null) {
            appService.installApp(filePath, widget.packageName);
          }
        },
        child: Text(
          "Install",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () {
        // Schedule state change for microtask boundary to prevent MouseTracker collision
        Future.microtask(() {
          ref
              .read(downloadServiceProvider.notifier)
              .downloadApp(
                packageName: widget.packageName,
                url: widget.downloadUrl,
                name: widget.name,
              );
        });
      },
      child: const Text("Get"),
    );
  }
}
