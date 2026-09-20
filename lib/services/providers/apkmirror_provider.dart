import 'package:aprecture/services/logger.dart';
import 'package:aprecture/services/providers/app_source.dart';

class ApkMirrorProvider extends AppSource {
  @override
  String get sourceName => 'APKMirror';

  @override
  bool get isOptIn => true;

  @override
  Future<Map<String, dynamic>> fetchApps() async {
    logger.w('APKMirror is intentionally disabled: anti-bot protection and scraping risk make it unsafe for the default app source.');
    return {};
  }
}
