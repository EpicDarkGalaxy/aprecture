import 'dart:convert';
import 'package:aprecture/models//app.dart';
import 'package:http/http.dart' as http;

class FdroidProvider {
  Future<Map<String, dynamic>> getApps() async {
    final response = await http.get(
      Uri.parse('https://f-droid.org/repo/index-v1.json'),
    );
    if (response.statusCode == 200) {
      final body = response.body;
      final data = jsonDecode(body);
      print("Data: ${data.runtimeType}");
      final packages = data['packages'];
      print("Packages: ${packages.runtimeType}");
      return packages;
    }
    return {};
  }
}

void main() async {
  final provider = FdroidProvider();
  final Map<String, dynamic> apps = await provider.getApps();
  final appsObjs = [];
  for (final app in apps.entries) {
    final appObj = App.fromJson(packageName: app.key, json: app.value);
    appsObjs.add(appObj);
  }
  print(appsObjs);
}
