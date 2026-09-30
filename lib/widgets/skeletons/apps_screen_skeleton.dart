import 'package:flutter/material.dart';
import 'box_skeleton.dart';

class AppsScreenSkeleton extends StatelessWidget {
  const AppsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: BoxSkeleton(width: 100, height: 200),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: BoxSkeleton(width: 100, height: 100),
            );
          },
        ),
      ),
    );
  }
}
