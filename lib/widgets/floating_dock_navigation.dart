import 'dart:ffi';

import 'package:flutter/material.dart';

class FloatingDockNavigation extends StatefulWidget {
  const FloatingDockNavigation({
    super.key,
    required this.dockItems,
    required this.initialIndex,
    required this.onTap,
  });

  final List<String> dockItems;
  final int initialIndex;
  final Function(int) onTap;

  @override
  State<FloatingDockNavigation> createState() => _FloatingDockNavigationState();
}

class _FloatingDockNavigationState extends State<FloatingDockNavigation> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 116,
      bottom: 16,
      child: FloatingDock(
        dockItems: widget.dockItems,
        onItemTapped: (index) => widget.onTap(index),
      ),
    );
  }
}

class FloatingDock extends StatelessWidget {
  const FloatingDock({
    super.key,
    required this.dockItems,
    required this.onItemTapped,
  });

  final List<String> dockItems;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Comfortable dock height
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Container shrinks/grows with the items
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          dockItems.length,
          (index) => _DockItem(
            title: dockItems[index],
            onTap: () => onItemTapped(index),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatefulWidget {
  const _DockItem({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(4),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(widget.title),
        ),
      ),
    );
  }
}
