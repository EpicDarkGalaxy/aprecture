abstract class AppSource {
  String get sourceName;

  bool get isOptIn => false;

  Future<Map<String, dynamic>> fetchApps();
}
