import 'package:flutter/material.dart';
import 'package:aprecture/services/logger.dart';

class AssetService {
  static final Map<String, dynamic> _iconCache = {};

  static dynamic getIcon(String iconUrl) {
    if (iconUrl.isEmpty) {
      return Icon(Icons.android);
    }

    if (_iconCache.containsKey(iconUrl)) {
      logger.d('Cache hit: $iconUrl');
      return _iconCache[iconUrl];
    }

    try {
      logger.d('Fetching icon: $iconUrl');
      _iconCache[iconUrl] = Image.network(iconUrl);
      return _iconCache[iconUrl];
    } catch(e) {
      return Icon(Icons.android);
    }
  }
}
