import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDeviceIDProvider = StateProvider<String>((ref) => '');

final connectedDeviceIDProvider = StateProvider<String>((ref) => '');
