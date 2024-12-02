import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rutoken_flutter/models/device_type.dart';
import 'package:rutoken_flutter/models/rutoken_device.dart';

import 'rutoken_flutter_method_channel.dart';

abstract class RutokenFlutterPlatform extends PlatformInterface {
  RutokenFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static final RutokenFlutterPlatform _instance = MethodChannelRutokenFlutter();

  static RutokenFlutterPlatform get instance => _instance;

  Stream<List<RutokenDevice>> get deviceStream;

  Future<void> initialize({
    required List<RutokenDeviceType> types,
  });
}
