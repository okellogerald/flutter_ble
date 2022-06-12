import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bluetooth_peripheral.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'circular'),
        color: Colors.lightBlue,
        debugShowCheckedModeBanner: false,
        home: const PermissionPage(),
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
    if (isEnabled) return const PeripheralApp();
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Enable Bluetooth And Click REFRESH'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: TextButton(
                onPressed: _checkIfBluetoothIsEnabled,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(double.maxFinite, 40)),
                child: const Text('REFRESH')),
          ),
        ],
      )),
    );
  }

  void _checkIfBluetoothIsEnabled() async {
    bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {});
  }
}
