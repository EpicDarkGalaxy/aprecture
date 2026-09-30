import 'package:flutter/material.dart';

class BoxSkeleton extends StatelessWidget {
  const BoxSkeleton({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
