import 'package:flutter/material.dart';
import 'package:aprecture/screens/navigation_shell.dart';

void main() {
  runApp(const Aprecture());
}

class Aprecture extends StatelessWidget {
  const Aprecture({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aprecture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationShell(),
    );
  }
}
