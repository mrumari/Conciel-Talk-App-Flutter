import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void callPhoneNumber(String phoneNumber) async {
  late PermissionStatus status;
  bool first = true;

  status = await Permission.phone.status;
  if (status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    await Permission.phone.request();
  }
  if (status.isGranted) {
    if (first) {
      first = false;
      if (Platform.isAndroid) {
        const platform = MethodChannel('samples.flutter.dev/phone');
        try {
          await platform
              .invokeMethod('makePhoneCall', {'phoneNumber': phoneNumber});
        } on PlatformException catch (e) {
          throw 'Error Occurred: ${e.message}';
        }
      }
      if (Platform.isIOS) {
        // Handle other platforms
      }
    }
  } else {
    // The permission is permanently denied or the user denied the permission this time.
    // You can show a dialog explaining why the app needs this permission and how to enable it in the app settings.
  }
}
