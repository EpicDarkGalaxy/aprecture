import 'package:flutter/material.dart';

class AssetManager {
  static dynamic getIcon(String iconUrl) {

    try {
      if (iconUrl.isEmpty) {
        return Icon(Icons.android);
      }
      return Image.network(iconUrl);
    } catch (e) {
      return Icon(Icons.android);
    }
  }
}
