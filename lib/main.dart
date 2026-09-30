import 'package:aprecture/services/theme/app_theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprecture/screens/navigation_shell.dart';
import 'package:aprecture/services/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprecture/screens/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Aprecture(),
    ),
  );
}

class Aprecture extends ConsumerWidget {
  const Aprecture({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(appThemeServiceProvider);

    return MaterialApp.router(
      title: 'Aprecture',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: getThemeMode(activeTheme),
      routerConfig: router,
    );
  }
}
