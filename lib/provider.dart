import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DiscoveryState { none, loading, done }

enum BondState { none, loading, done }

extension DiscoveryStateExtension on DiscoveryState {
  bool get isLoading => this == DiscoveryState.loading;
  bool get isDone => this == DiscoveryState.done;
}

extension BondStateExtension on BondState {
  bool get isLoading => this == BondState.loading;
  bool get isDone => this == BondState.done;
}

final selectedDeviceIDProvider = StateProvider<String>((ref) => '');

final devicesProvider = StateProvider<List<BluetoothDiscoveryResult>>(
    (ref) => <BluetoothDiscoveryResult>[]);

final discoveryStateProvider =
    StateProvider<DiscoveryState>((ref) => DiscoveryState.none);

final bondStateProvider = StateProvider<BondState>((ref) => BondState.none);
