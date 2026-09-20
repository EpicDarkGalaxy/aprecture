import 'package:aprecture/services/providers/fdroid_provider.dart';
import 'package:aprecture/services/providers/izzy_on_droid_provider.dart';
import 'package:aprecture/services/providers/apkmirror_provider.dart';

final Map<String, dynamic> providersMap = {
  "Default": {
    "F-Droid": FdroidProvider(),
    "IzzyOnDroid": IzzyOnDroidProvider(),
  },
  "Opt-In": {
    "APKMirror": ApkMirrorProvider(),
  },
};