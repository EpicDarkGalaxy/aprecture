import 'package:flutter/material.dart';
import 'package:aprecture/services/providers/fdroid_provider.dart';
import 'package:aprecture/models/app.dart';
import 'package:logger/logger.dart';
import 'package:aprecture/services/asset_manager.dart';
import 'package:aprecture/screens/app_details_screen.dart';


class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  final logger = Logger();
  late final Future<List<App>> _apps;

  @override
  void initState() {
    super.initState();
    logger.d("Fetching apps...");
    _apps = FdroidProvider().getApps();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apps")),
      body: Center(
        child: FutureBuilder(
          future: _apps,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: AssetManager.getIcon(snapshot.data?[index].iconUrl ?? ""),
                    ),
                    title: Text(snapshot.data?[index].name ?? "NONAME"),
                    subtitle: Text(snapshot.data?[index].summary ?? "SUMMARY?"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppDetailsScreen(app: snapshot.data![index]),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
