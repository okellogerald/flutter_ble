import 'dart:developer';
import 'package:bluetoothflutterblue/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_entry.dart';

class DeviceTile extends ConsumerStatefulWidget {
  const DeviceTile(this.device, this.rssi, {Key? key}) : super(key: key);
  final BluetoothDevice device;
  final int rssi;

  @override
  ConsumerState<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends ConsumerState<DeviceTile> {
  @override
  Widget build(BuildContext context) {
    final selectedDeviceID = ref.watch(selectedDeviceIDProvider);
    final bondState = ref.watch(bondStateProvider);
    log(widget.device.bondState.toString());

    return Column(
      children: [
        BluetoothDeviceListEntry(
          device: widget.device,
          rssi: widget.rssi,
          onTap: () => ref.read(selectedDeviceIDProvider.state).state =
              widget.device.address,
        ),
        if (selectedDeviceID == widget.device.address && !widget.device.isBonded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
                onPressed: _onConnectClick,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(double.maxFinite, 40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bondState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: CupertinoActivityIndicator(color: Colors.white),
                      ),
                    const Text('CONNECT'),
                  ],
                )),
          ),
        if (selectedDeviceID == widget.device.address && widget.device.isBonded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
                onPressed: _onDisconnectClick,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    fixedSize: const Size(double.maxFinite, 40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bondState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: CupertinoActivityIndicator(color: Colors.white),
                      ),
                    const Text('DISCONNECT',
                        style: TextStyle(color: Colors.white)),
                  ],
                )),
          )
      ],
    );
  }

  _onConnectClick() async {
    final address = widget.device.address;
    try {
      log('Bonding with $address}...');
      ref.read(bondStateProvider.state).state = BondState.loading;
      final bonded = (await FlutterBluetoothSerial.instance
          .bondDeviceAtAddress(widget.device.address))!;
      if (bonded) {
        final devices =
            List<BluetoothDiscoveryResult>.from(ref.read(devicesProvider));
        final index = devices.indexWhere((e) => e.device.address == address);
        if (index != -1) {
          devices[index] = BluetoothDiscoveryResult(
              device: BluetoothDevice(
                  name: widget.device.name ?? 'UNKNOWN',
                  address: widget.device.address,
                  type: widget.device.type,
                  bondState: BluetoothBondState.bonded),
              rssi: widget.rssi);
        }
        ref.read(devicesProvider.state).state = devices;
      }
      ref.read(bondStateProvider.state).state = BondState.done;
      log('Bonding with $address} has ${bonded ? 'succeded' : 'failed'}.');
    } catch (error) {
      ref.read(bondStateProvider.state).state = BondState.done;
      _showErrorDialog('$error');
    }
  }

  _onDisconnectClick() async {
    final address = widget.device.address;
    try {
      log('Unbonding from $address}...');
      ref.read(bondStateProvider.state).state = BondState.loading;
      await FlutterBluetoothSerial.instance
          .removeDeviceBondWithAddress(widget.device.address);
      final devices =
          List<BluetoothDiscoveryResult>.from(ref.read(devicesProvider));
      final index = devices.indexWhere((e) => e.device.address == address);
      if (index != -1) {
        devices[index] = BluetoothDiscoveryResult(
            device: BluetoothDevice(
                name: widget.device.name ?? 'UNKNOWN',
                address: widget.device.address,
                type: widget.device.type,
                bondState: BluetoothBondState.none),
            rssi: widget.rssi);
      }
      ref.read(devicesProvider.state).state = devices;
      ref.read(bondStateProvider.state).state = BondState.done;
      log('Unbonding from $address} has succed');
    } catch (error) {
      ref.read(bondStateProvider.state).state = BondState.done;
      _showErrorDialog('$error');
    }
  }

  _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error occured while unbonding'),
          content: Text(message),
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
