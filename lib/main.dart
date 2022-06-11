import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'discovery.dart';

void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'circular'),
        color: Colors.lightBlue,
        debugShowCheckedModeBanner: false,
        home: const DiscoveryPage(),
      ),
    );
  }
}

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  BluetoothState? bluetoothState;

  @override
  void initState() {
    _checkIfBluetoothIsEnabled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = bluetoothState?.isEnabled ?? false;
    if (isEnabled) return const DiscoveryPage();
    return const Scaffold(
      body: Center(child: Text('Enable Bluetooth!')),
    );
  }

  void _checkIfBluetoothIsEnabled() async {
    bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {});
  }
}
