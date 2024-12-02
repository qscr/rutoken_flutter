import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutoken_flutter/rutoken_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelRutokenFlutter platform = MethodChannelRutokenFlutter();
  const MethodChannel channel = MethodChannel('rutoken_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
