import 'package:rutoken_flutter/models/rutoken_device.dart';

enum RutokenDeviceEventType {
  added,
  removed;

  const RutokenDeviceEventType();

  static RutokenDeviceEventType fromString(String type) {
    return values.firstWhere((e) => e.name == type);
  }
}

class RutokenDeviceEvent {
  RutokenDeviceEvent({
    required this.type,
    required this.name,
  });

  factory RutokenDeviceEvent.fromJSON(Map<String, dynamic> json) {
    return RutokenDeviceEvent(
      type: RutokenDeviceEventType.fromString(json['type']),
      name: json['deviceName'],
    );
  }

  RutokenDevice toDevice() {
    return RutokenDevice(name: name);
  }

  final RutokenDeviceEventType type;

  final String name;
}
