import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class PeripheralApp extends StatefulWidget {
  const PeripheralApp({Key? key}) : super(key: key);

  @override
  PeripheralAppState createState() => PeripheralAppState();
}

class PeripheralAppState extends State<PeripheralApp> {
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();

  final AdvertiseData advertiseData = AdvertiseData(
    serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
    manufacturerId: 1234,
    includeDeviceName: true,
    includePowerLevel: true,
    localName: 'My Device',
    manufacturerData: Uint8List.fromList([1, 2, 3, 4, 5, 6]),
  );

  final AdvertiseSettings advertiseSettings = AdvertiseSettings(
    advertiseMode: AdvertiseMode.advertiseModeBalanced,
    txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
    timeout: 3000,
  );

  final AdvertiseSetParameters advertiseSetParameters = AdvertiseSetParameters(
    txPowerLevel: txPowerMedium,
  );

  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final isSupported = await blePeripheral.isSupported;
    setState(() {
      _isSupported = isSupported;
    });
  }

  Future<void> _toggleAdvertise() async {
    if (await blePeripheral.isAdvertising) {
      await blePeripheral.stop();
    } else {
      await blePeripheral.start(advertiseData: advertiseData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter BLE Peripheral')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Is supported: $_isSupported'),
            StreamBuilder(
              stream: blePeripheral.onPeripheralStateChanged,
              initialData: PeripheralState.unknown,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return Text(
                  'State: ${describeEnum(snapshot.data as PeripheralState)}',
                );
              },
            ),
            // StreamBuilder(
            //     stream: blePeripheral.getDataReceived(),
            //     initialData: 'None',
            //     builder:
            //         (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            //       return Text('Data received: ${snapshot.data}');
            //     },),
            Text('Current UUID: ${advertiseData.serviceUuid}'),
            MaterialButton(
              onPressed: _toggleAdvertise,
              child: Text(
                'Toggle advertising',
                style: Theme.of(context)
                    .primaryTextTheme
                    .button!
                    .copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
