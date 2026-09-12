import 'package:aprecture/services/asset_service.dart';
import 'package:flutter/material.dart';
import 'package:aprecture/models/app.dart';
import 'package:aprecture/screens/app_details_screen.dart';
// import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/app_service.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _appService = AppService();

  List<App> _filteredApps = [];
  String _query = '';

  void _filterApps() {
    setState(() {
      if (_query.isEmpty) {
        _filteredApps = [];
        return;
      }

      _filteredApps = _appService.searchApps(_query);
    });
  }

  Widget _buildSearchResults() {
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
          leading: SizedBox(
            width: 48,
            height: 48,
            child: AssetService.getIcon(_filteredApps[index].iconUrl),
          ),
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
