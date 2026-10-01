import 'dart:async';
import 'package:flutter/services.dart';

class PackageEvent {
  final String packageName;
  final String eventType;

  PackageEvent({required this.packageName, required this.eventType});
}

class PackageEvents {
  static const EventChannel _packageEventChannel = EventChannel(
    'com.epic.aprecture/package_events',
  );
  late final StreamSubscription _subscription;
  final _callbacks = <Function(PackageEvent)>[];

  void startListening(Function(PackageEvent) callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
    _subscription = _packageEventChannel.receiveBroadcastStream().listen((
      event,
    ) {
      (dynamic event) {
        final payload = PackageEvent(
          eventType: event?['eventType'] ?? '',
          packageName: event?['packageName'] ?? '',
        );
        for (final callback in _callbacks) {
          callback(payload);
        }
      }(event);
    });
  }

  void stopListening() {
    _subscription.cancel();
  }
}
