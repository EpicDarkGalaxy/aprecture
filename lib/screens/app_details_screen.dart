import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/app_service.dart';
import 'package:aprecture/widgets/get_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:aprecture/services/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsScreen extends ConsumerStatefulWidget {
  final String _appId;

  const AppDetailsScreen({super.key, required this._appId});

  @override
  ConsumerState<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends ConsumerState<AppDetailsScreen> {
  late App app;

  late String _selectedSource;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    app = ref.read(appServiceProvider.notifier).getApp(widget._appId);

    _selectedSource = app.sourceNames.isNotEmpty
        ? app.sourceNames.keys.first
        : '';
  }

  Widget _buildAppIcon(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 96,
        height: 96,
        color: colorScheme.surfaceContainerHigh,
        child: app.iconUrl.isNotEmpty
            ? Image.network(
                app.iconUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.android,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : Icon(
                Icons.android,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }

  Widget _buildSourcesDropdown(ColorScheme colorScheme) {
    if (app.sourceNames.isEmpty) return const SizedBox.shrink();

    return DropdownMenu<String>(
      initialSelection: _selectedSource,
      label: const Text('Source'),
      onSelected: (String? value) {
        if (value != null) {
          setState(() {
            _selectedSource = value;
          });
          logger.d("Selected Source: $_selectedSource");
        }
      },
      dropdownMenuEntries: app.sourceNames.keys.map((source) {
        return DropdownMenuEntry(value: source, label: source);
      }).toList(),
    );
  }

  Widget _buildExternalLinks() {
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
            avatar: const Icon(Icons.code, size: 18),
            label: const Text('Source Code'),
            onPressed: () => launchUrl(Uri.parse(app.sourceCode)),
          ),
        if (app.issueTracker.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.bug_report, size: 18),
            label: const Text('Issue Tracker'),
            onPressed: () => launchUrl(Uri.parse(app.issueTracker)),
          ),
        if (app.webSite.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.language, size: 18),
            label: const Text('Website'),
            onPressed: () => launchUrl(Uri.parse(app.webSite)),
          ),
      ],
    );
  }

  Widget _buildAppName(TextTheme textTheme, ColorScheme colorScheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (app.versionName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              app.versionName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeveloper(TextTheme textTheme, ColorScheme colorScheme) {
    if (app.author.isEmpty) return const SizedBox.shrink();

    return Text.rich(
      TextSpan(
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        children: [
          const TextSpan(text: 'By '),
          TextSpan(
            text: app.author,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategories(ColorScheme colorScheme, TextTheme textTheme) {
    if (app.categories.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: app.categories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScreenshots(ColorScheme colorScheme) {
    if (app.screenshots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
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
                    color: colorScheme.surfaceContainerHigh,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        color: colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 120,
                          color: colorScheme.surfaceContainerHigh,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
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

  Widget _buildDescription(ColorScheme colorScheme, TextTheme textTheme) {
    if (app.description.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          setState(() {
            _descriptionExpanded = !_descriptionExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.description,
                maxLines: _descriptionExpanded ? null : 3,
                overflow: _descriptionExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _descriptionExpanded ? 'Read less' : 'Read more',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _descriptionExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(app.name), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: App Icon + App Name & Version
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppIcon(colorScheme),
                const SizedBox(width: 16.0),
                _buildAppName(textTheme, colorScheme),
              ],
            ),
            const SizedBox(height: 16.0),

            // Get / Download Action Row
            SizedBox(
              width: double.infinity,
              child: GetButton(
                name: app.name,
                packageName: app.packageName,
                downloadUrl: app.downloadUrl(
                  _selectedSource.isNotEmpty
                      ? _selectedSource
                      : (app.sourceNames.isNotEmpty
                            ? app.sourceNames.keys.first
                            : ''),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Developer & Categories
            _buildDeveloper(textTheme, colorScheme),
            const SizedBox(height: 8.0),
            _buildCategories(colorScheme, textTheme),
            const SizedBox(height: 16.0),

            // Sources Dropdown & External Action Links
            _buildSourcesDropdown(colorScheme),
            const SizedBox(height: 12.0),
            _buildExternalLinks(),
            const SizedBox(height: 20.0),

            // Screenshots Gallery
            _buildScreenshots(colorScheme),
            const SizedBox(height: 20.0),

            // Description Box
            _buildDescription(colorScheme, textTheme),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
