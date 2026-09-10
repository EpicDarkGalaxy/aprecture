import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/asset_manager.dart';
import 'package:flutter/material.dart';

class AppDetailsScreen extends StatelessWidget {
  final App app;
  const AppDetailsScreen({super.key, required this.app});


  Widget appIcon() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CircleAvatar(
        child: AssetManager.getIcon(app.iconUrl),
      ),
    );
  }

  Widget appName() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            "V${app.versionName}",
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
      onPressed: () {
        print("INSTALLING");
      },
      child: const Text('Get'),
    );
  }

  Widget appDescription() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade400, width: 2.0),
          ),
          child: Text(
            app.description,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                appIcon(),
                const SizedBox(width: 16.0),
                appName(),
                const SizedBox(width: 16.0),
                SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      appGetButton(),
                    ],
                  )
                )
              ],
            ),
            const SizedBox(height: 64.0),
            appDescription(),
          ],
        ),
      ),
    );
  }

}
