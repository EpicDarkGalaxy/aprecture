import 'package:aprecture/services/app_providers/fdroid_provider.dart';
import 'package:aprecture/services/app_providers/izzy_on_droid_provider.dart';
import 'package:aprecture/services/app_providers/apkmirror_provider.dart';

final Map<String, dynamic> providersMap = {
  "Default": {
    "F-Droid": FdroidProvider(),
    "IzzyOnDroid": IzzyOnDroidProvider(),
  },
  "Opt-In": {"APKMirror": ApkMirrorProvider()},
};
