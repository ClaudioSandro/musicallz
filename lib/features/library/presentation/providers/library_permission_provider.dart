import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final libraryPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return PermissionStatus.granted;
  }

  final androidInfo = await DeviceInfoPlugin().androidInfo;
  if (androidInfo.version.sdkInt >= 33) {
    // Android 13+ requires READ_MEDIA_AUDIO.
    return Permission.audio.request();
  }
  // Android 12 and earlier use the storage permission.
  return Permission.storage.request();
});