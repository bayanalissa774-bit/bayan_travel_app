import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class ProfileStore {
  ProfileStore._();

  static final ValueNotifier<String> userName =
      ValueNotifier<String>('Bayan Alissa');

  static final ValueNotifier<Uint8List?> profileImage =
      ValueNotifier<Uint8List?>(null);
}
