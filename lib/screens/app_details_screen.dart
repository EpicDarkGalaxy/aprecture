import 'package:aprecture/models/app.dart';
import 'package:flutter/material.dart';
import 'package:aprecture/services/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsScreen extends StatelessWidget {
  final App app;

  const AppDetailsScreen({super.key, required this.app});

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

  Widget appExternalLinks() {
    if (app.sourceCode.isEmpty && app.issueTracker.isEmpty && app.webSite.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.code),
          label: const Text('Source Code'),
          onPressed: () => launchUrl(Uri.parse(app.sourceCode)),
        ),
        ActionChip(
          avatar: const Icon(Icons.bug_report),
          label: const Text('Issue Tracker'),
          onPressed: () => launchUrl(Uri.parse(app.issueTracker)),
        ),
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
          )
        ],
      ),
    );
  }

  Widget appGetButton() {
    return ElevatedButton(
      onPressed: () {
        logger.d("INSTALLING");
      },
      child: const Text('Get'),
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
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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
    return ExpansionTile(
      title: const Text('Description'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade400, width: 2.0),
          ),
          child: Text(app.description, style: const TextStyle(fontSize: 16)),
        ),
      ],
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [appGetButton()],
                  ),
                ),
              ],
            ),
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
