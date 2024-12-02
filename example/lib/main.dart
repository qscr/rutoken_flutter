import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rutoken_flutter/models/device_type.dart';
import 'package:rutoken_flutter/models/rutoken_device.dart';
import 'package:rutoken_flutter/rutoken_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _rutokenFlutterPlugin = RutokenFlutter();
  StreamSubscription<List<RutokenDevice>>? sub;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final perm = await Permission.bluetoothConnect.request();
      await _rutokenFlutterPlugin.initialize(
        types: [RutokenDeviceType.bluetooth, RutokenDeviceType.usb],
      );
      sub = _rutokenFlutterPlugin.deviceStream.listen((data) {
        print(data.firstOrNull?.name);
        sub?.cancel();
      });
      platformVersion = 'Success';
    } on PlatformException {
      platformVersion = 'Failed';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
