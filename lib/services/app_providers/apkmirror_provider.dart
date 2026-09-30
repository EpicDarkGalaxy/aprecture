import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/app_providers/app_source_abstract.dart';

class ApkMirrorProvider extends AppSource {
  @override
  String get sourceName => 'APKMirror';

  @override
  bool get isOptIn => true;

  @override
  Future<Map<String, dynamic>> fetchApps() async {
    logger.w(
      'APKMirror is configured as an opt-in experimental source. '
      'This build intentionally avoids scraping APKMirror HTML, because the site is brittle and the app should remain stable by default.',
    );

    // TODO: Replace with a confirmed stable JSON endpoint or official API.
    // Until then, keep it disabled-by-default and return no apps.
    return {};
  }
}
