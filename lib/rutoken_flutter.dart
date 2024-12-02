import 'package:rutoken_flutter/models/device_type.dart';
import 'package:rutoken_flutter/models/rutoken_device.dart';
import 'package:rutoken_flutter/rutoken_flutter_platform_interface.dart';

class RutokenFlutter {
  Future<void> initialize({
    required List<RutokenDeviceType> types,
  }) async {
    await RutokenFlutterPlatform.instance.initialize(types: types);
  }

  Stream<List<RutokenDevice>> get deviceStream =>
      RutokenFlutterPlatform.instance.deviceStream;
}
