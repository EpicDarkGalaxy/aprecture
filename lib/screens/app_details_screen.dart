import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/download_service.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:aprecture/services/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsScreen extends StatefulWidget {
  final App _app;

  const AppDetailsScreen({super.key, required this._app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsSreenState();
}

class _AppDetailsSreenState extends State<AppDetailsScreen> {
  final DownloadService _downloadService = DownloadService();
  final AppService _appService = AppService();
  App get app => widget._app;

  String _selectedSource = '';
  bool _descriptionExpanded = false;

  Widget appIcon() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CircleAvatar(
        child: app.iconUrl.isNotEmpty
            ? Image.network(
                app.iconUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.android),
              )
            : const Icon(Icons.android),
      ),
    );
  }

  Widget appSources() {
    return DropdownMenu(
      initialSelection: app.sourceNames.isNotEmpty
          ? app.sourceNames.keys.first
          : null,
      selectOnly: true,
      label: const Text('Sources'),
      dropdownMenuEntries: app.sourceNames.keys.map((source) {
        _selectedSource = source;
        logger.d("Selected Source: $_selectedSource");
        return DropdownMenuEntry(value: source, label: source);
      }).toList(),
    );
  }

  Widget appExternalLinks() {
    // Test
    logger.d(
      "External Links: ${app.sourceCode}, ${app.issueTracker}, ${app.webSite}",
    );

    if (app.sourceCode.isEmpty &&
        app.issueTracker.isEmpty &&
        app.webSite.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (app.sourceCode.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.code),
            label: const Text('Source Code'),
            onPressed: () => launchUrl(Uri.parse(app.sourceCode)),
          ),
        if (app.issueTracker.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.bug_report),
            label: const Text('Issue Tracker'),
            onPressed: () => launchUrl(Uri.parse(app.issueTracker)),
          ),
        if (app.webSite.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.web),
            label: const Text('Website'),
            onPressed: () => launchUrl(Uri.parse(app.webSite)),
          ),
      ],
    );
  }

  Widget appName() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            app.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            app.versionName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            app.author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            app.categories.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget appGetButton() {
    return ElevatedButton(
      onPressed: () => _downloadService.downloadApp(
        url: app.downloadUrl(_selectedSource),
        packageName: app.packageName,
      ),
      child: Text("Get"),
    );
  }

  Widget appInstallButton() {
    return ElevatedButton(
      onPressed: () => _appService.installApp(
        _downloadService.getFilePath(app.packageName)!,
      ),
      child: Text("Install"),
    );
  }

  Widget appOpenButton() {
    return ElevatedButton(
      onPressed: () => _appService.openApp(app.packageName),
      child: Text("Open"),
    );
  }

  // Widget appUninstallButton() {
  //   return ElevatedButton(
  //     onPressed: () => _appService.uninstallApp(app.packageName),
  //     child: Text("Uninstall"),
  //   );
  // }

  Widget appDownloadProgress() {
    return ListenableBuilder(
      listenable: _downloadService,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              child: CircularProgressIndicator(
                value: _downloadService.getProgress(app.packageName),
              ),
            ),
            Text(
              '${(_downloadService.getProgress(app.packageName) * 100).round()}%',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        );
      },
    );
  }

  Widget appScreenshots() {
    if (app.screenshots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Screenshots',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: app.screenshots.length,
            itemBuilder: (context, index) {
              final url = app.screenshots[index];
              if (url.isEmpty || !url.startsWith('http')) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.grey.shade200,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget appDescription() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _descriptionExpanded = !_descriptionExpanded;
        });
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade400, width: 2.0),
            ),
            child: Column(
              children: [
                Text(
                  app.description,
                  style: const TextStyle(fontSize: 16),
                  maxLines: _descriptionExpanded ? null : 3,
                  overflow: _descriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                HtmlWidget(
                  app.description,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDownloadActionButton() {
    return FutureBuilder<bool>(
      future: _appService.isAppInstalled(app.packageName),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return appOpenButton();
        }
        if (_downloadService.isDownloading(app.packageName) &&
            !_downloadService.isCompleted(app.packageName)) {
          return appDownloadProgress();
        }
        if (_downloadService.isCompleted(app.packageName)) {
          return appInstallButton();
        }
        return appGetButton();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(app.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appIcon(),
                const SizedBox(width: 16.0),
                appName(),
                const SizedBox(width: 16.0),
                SizedBox(
                  height: 100,
                  child: ListenableBuilder(
                    listenable: _downloadService,
                    builder: (context, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [buildDownloadActionButton()],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            appSources(),
            const SizedBox(height: 16.0),
            appExternalLinks(),
            const SizedBox(height: 16.0),
            appScreenshots(),
            const SizedBox(height: 16.0),
            appDescription(),
            const SizedBox(height: 64.0),
          ],
        ),
      ),
    );
  }
}
