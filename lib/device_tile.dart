import 'dart:developer';
import 'package:bluetoothflutterblue/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_entry.dart';

class DeviceTile extends ConsumerStatefulWidget {
  const DeviceTile(this.device, this.rssi,
      {required this.onConnected, Key? key})
      : super(key: key);
  final BluetoothDevice device;
  final int rssi;
  final ValueChanged<bool> onConnected;

  @override
  ConsumerState<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends ConsumerState<DeviceTile> {
  late BluetoothDevice device;

  @override
  void initState() {
    device = widget.device;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDeviceID = ref.watch(selectedDeviceIDProvider);
    final connectedDeviceID = ref.watch(connectedDeviceIDProvider);

    return Column(
      children: [
        BluetoothDeviceListEntry(
          device: widget.device,
          rssi: widget.rssi,
          onTap: () => ref.read(selectedDeviceIDProvider.state).state =
              widget.device.address,
        ),
        if (selectedDeviceID == widget.device.address)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
                onPressed: _onConnectClick,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(double.maxFinite, 40)),
                child: const Text('CONNECT')),
          ),
        if (connectedDeviceID == widget.device.address)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
                onPressed: _onDisconnectClick,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(double.maxFinite, 40)),
                child: const Text('DISCONNECT')),
          )
      ],
    );
  }

  _onConnectClick() async {
    final address = device.address;
    try {
      log('Bonding with $address}...');
      final bonded = (await FlutterBluetoothSerial.instance
          .bondDeviceAtAddress(device.address))!;
      if (bonded) {
        ref.refresh(selectedDeviceIDProvider);
        ref.read(connectedDeviceIDProvider.state).state = device.address;
      }
      log('Bonding with $address} has ${bonded ? 'succed' : 'failed'}.');

      widget.onConnected(bonded);
    } catch (ex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while bonding'),
            content: Text(ex.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  _onDisconnectClick() async {
    final address = device.address;
    try {
      log('Unbonding from $address}...');
      await FlutterBluetoothSerial.instance
          .removeDeviceBondWithAddress(device.address);
      ref.refresh(connectedDeviceIDProvider);
      log('Unbonding from $address} has succed');
    } catch (ex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while unbonding'),
            content: Text(ex.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
