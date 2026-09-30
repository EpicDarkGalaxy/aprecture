import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/widgets/get_button.dart'; // adjust path if needed

class AppsListItem extends ConsumerWidget {
  final App app;
  final VoidCallback onTap;

  const AppsListItem({super.key, required this.app, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Cache computed download URL
    final defaultSource = app.sourceNames.keys.firstOrNull ?? '';
    final downloadUrl = defaultSource.isNotEmpty
        ? app.downloadUrl(defaultSource)
        : '';

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: colorScheme.primary.withAlpha(25),
            highlightColor: colorScheme.primary.withAlpha(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 1. Optimized App Icon using CachedNetworkImage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: CachedNetworkImage(
                        imageUrl: app.iconUrl,
                        fit: BoxFit.cover,
                        memCacheWidth:
                            128, // Downsample image to conserve memory
                        memCacheHeight: 128,
                        placeholder: (context, url) =>
                            Container(color: colorScheme.surfaceContainerHigh),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.android,
                            size: 32,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 2. Title & Summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          app.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (app.categories.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              app.categories.first,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 3. Isolated Button
                  Focus(
                    canRequestFocus: false,
                    descendantsAreFocusable: true,
                    child: RepaintBoundary(
                      child: GetButton(
                        name: app.name,
                        packageName: app.packageName,
                        downloadUrl: downloadUrl,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
