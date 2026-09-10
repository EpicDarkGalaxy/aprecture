import 'package:aprecture/services/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/services/providers/fdroid_provider.dart';
import 'package:aprecture/screens/app_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<App> _filteredApps = [];
  final List<App> _apps = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await FdroidProvider().getApps();
    if (!mounted) return;
    setState(() {
      _apps.addAll(apps);
      _loading = false;
    });
  }

  void _filterApps() {
    if (_query.isNotEmpty) {
      setState(() {
        _filteredApps.clear();
        for (final app in _apps) {
          final loweredAppName = app.name.toLowerCase();
          final loweredQuery = _query.toLowerCase();
          final loweredAppSummary = app.summary.toLowerCase();
          final loweredCategories = app.categories.map((c) => c.toLowerCase()).toList();

          if (loweredAppName.contains(loweredQuery) || loweredAppSummary.contains(loweredQuery) || loweredCategories.contains(loweredQuery)) {
            print("Found: ${app.name}");
            _filteredApps.add(app);
          }
        }
      });
    }
  }

  Widget _buildSearchResults() {
    if(_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_query.isEmpty) {
      return const Center(child: Text("Search for an app"));
    }
    if (_filteredApps.isEmpty) {
      return const Center(child: Text("No results"));
    }

    return ListView.builder(
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: AssetManager.getIcon(_filteredApps[index].iconUrl),
          title: Text(_filteredApps[index].name),
          subtitle: Text(_filteredApps[index].summary),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AppDetailsScreen(app: _filteredApps[index])));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: "Search>>>",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _query = value;
            _filterApps();
          },
        ),
      ),
      body: _buildSearchResults(),
    );
  }
}
