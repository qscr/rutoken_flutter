import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rutoken_flutter/models/device_type.dart';
import 'package:rutoken_flutter/models/rutoken_device.dart';
import 'package:rutoken_flutter/models/rutoken_device_event.dart';

import 'rutoken_flutter_platform_interface.dart';

/// An implementation of [RutokenFlutterPlatform] that uses method channels.
class MethodChannelRutokenFlutter extends RutokenFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rutoken_flutter');

  final eventChannel = const EventChannel('rutoken_flutter_devices');

  @override
  Future<void> initialize({
    required List<RutokenDeviceType> types,
  }) async {
    await methodChannel.invokeMethod<String>('initialize', {
      'isUSBEnabled': types.contains(RutokenDeviceType.usb),
      'isBluetoothEnabled': types.contains(RutokenDeviceType.bluetooth),
      'isNFCEnabled': types.contains(RutokenDeviceType.nfc),
    });
  }

  final List<RutokenDevice> _deviceList = [];

  StreamSubscription<dynamic>? _eventSubscription;

  void onListenCallback() {
    _eventSubscription = eventChannel.receiveBroadcastStream().listen((data) {
      final event = RutokenDeviceEvent.fromJSON(Map<String, dynamic>.from(
        data,
      ));
      if (event.type == RutokenDeviceEventType.added) {
        _deviceList.add(event.toDevice());
      } else {
        _deviceList.removeWhere((e) => e.name == event.name);
      }
      _deviceStreamController.add(_deviceList);
    });
  }

  late final _deviceStreamController =
      StreamController<List<RutokenDevice>>.broadcast(
    onListen: onListenCallback,
    onCancel: () {
      _eventSubscription?.cancel();
    },
  );

  @override
  Stream<List<RutokenDevice>> get deviceStream =>
      _deviceStreamController.stream;
}
