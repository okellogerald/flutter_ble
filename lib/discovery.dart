import 'dart:async';
import 'dart:math';
import 'package:bluetoothflutterblue/device_tile.dart';
import 'package:bluetoothflutterblue/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;
  const DiscoveryPage({this.start = true, Key? key}) : super(key: key);

  @override
  _DiscoveryPage createState() => _DiscoveryPage();
}

class _DiscoveryPage extends ConsumerState<DiscoveryPage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (widget.start) {
        ref.read(discoveryStateProvider.state).state = DiscoveryState.loading;
        _startDiscovery();
      }
    });
    super.initState();
  }

  void _restartDiscovery() {
    ref.refresh(devicesProvider);
    ref.read(discoveryStateProvider.state).state = DiscoveryState.loading;
    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      log(device.rssi);
      final devices =
          List<BluetoothDiscoveryResult>.from(ref.read(devicesProvider));
      devices.add(device);
      ref.read(devicesProvider.state).state = devices;
    });

    _streamSubscription!.onDone(() {
      ref.read(discoveryStateProvider.state).state = DiscoveryState.done;
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoveryStateProvider);
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: discoveryState.isLoading
            ? const Text('Discovering devices')
            : const Text('Discovered devices'),
        actions: <Widget>[
          discoveryState.isLoading
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = devices[index];
          return DeviceTile(result.device, result.rssi);
        },
      ),
    );
  }
}
