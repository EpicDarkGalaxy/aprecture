import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:aprecture/models/app.dart';

class HeroAppCard extends StatefulWidget {
  final App app;
  final VoidCallback onTap;

  const HeroAppCard({super.key, required this.app, required this.onTap});

  @override
  State<HeroAppCard> createState() => _HeroAppCardState();
}

class _HeroAppCardState extends State<HeroAppCard> {
  Color _cardColor = Colors.grey.shade900; // Default fallback color

  @override
  void initState() {
    super.initState();
    _extractPalette();
  }

  Future<void> _extractPalette() async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.app.iconUrl),
        size: const Size(64, 64),
      );
      if (mounted) {
        setState(() {
          // Use vibrant color, dominant color, or fallback
          _cardColor =
              paletteGenerator.vibrantColor?.color ??
              paletteGenerator.dominantColor?.color ??
              _cardColor;
        });
      }
    } catch (_) {
      // Fallback if image fails to load or extract
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 300,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            // Use the extracted icon color with an optional opacity or gradient blend
            gradient: LinearGradient(
              colors: [
                _cardColor.withValues(alpha: 0.95),
                Colors.black.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _cardColor.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Image.network(
                          widget.app.iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.android,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "By ${widget.app.author}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.app.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.app.versionName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.app.categories.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.app.summary,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
