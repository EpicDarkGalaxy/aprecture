import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service.g.dart';

@riverpod
class StorageService extends _$StorageService {
  @override
  Future<SharedPreferences> build() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await future;
    await prefs.setString('themeMode', themeMode);
  }

  String? getThemeMode() {
    return state.value?.getString('themeMode');
  }
}
