import 'package:aprecture/screens/app_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:aprecture/models/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aprecture/services/logger.dart';
import 'package:aprecture/widgets/apps_list_item.dart';
import 'package:aprecture/services/app_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List<App> _filteredApps = [];
  String _query = '';

  void _filterApps() {
    setState(() {
      if (_query.isEmpty) {
        _filteredApps = [];
        return;
      }

      _filteredApps = ref.read(appServiceProvider.notifier).searchApps(_query);
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
        return AppsListItem(
          app: _filteredApps[index],
          onTap: () {
            context.push('/app-details/${_filteredApps[index].appId}');
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
