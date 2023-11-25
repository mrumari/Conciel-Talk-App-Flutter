import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background/flutter_background.dart';

Future<Map<Permission, PermissionStatus>> requestPermissions() async {
  if (Platform.isAndroid) {
    final permissions = [
      Permission.phone,
      Permission.microphone,
      Permission.camera,
      Permission.location,
      Permission.contacts,
      Permission.mediaLibrary,
      Permission.photos,
      Permission.videos,
      Permission.audio,
      Permission.calendar,
      Permission.notification,
      Permission.reminders,
//    Permission.bluetooth, - need to resolve this
//    Permission.systemAlertWindow, - need to set the correct approach for this
    ];

    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        final newStatus = await permission.request();
        statuses[permission] = newStatus;
      } else {
        statuses[permission] = status;
      }
      Logs().i('$permission, $status');
    }
//  print(statuses);
    final pStatus = await requestReadPhoneNumbersPermission();
    Logs().i('Permission $pStatus');
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterBackground.initialize();

    return statuses;
  } else if (Platform.isIOS) {
    final statuses = <Permission, PermissionStatus>{};
    return statuses;
  } else {
    final statuses = <Permission, PermissionStatus>{};
    return statuses;
  }
}

Future<String> requestReadPhoneNumbersPermission() async {
  const platform = MethodChannel('chat.conciel.concieltalk/permissions');
  try {
    await platform.invokeMethod('requestReadPhoneNumbersPermission');
    return 'ReadPhoneNumbers: granted';
  } on PlatformException catch (e) {
    Logs().i('this did not work - request read phone numbers - $e');
    return 'ReadPhoneNumbers: denied - $e';
    // Handle the exception
  }
}

/* // In your custom Flutter plugin (Android part)
import android.app.role.RoleManager;
import android.content.Intent;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class DefaultAssistantPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private static final int REQUEST_CODE_SET_DEFAULT_ASSISTANT = 123;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "default_assistant");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("requestDefaultAssistant")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                RoleManager roleManager = (RoleManager) getSystemService(Context.ROLE_SERVICE);
                Intent intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_ASSISTANT);
                startActivityForResult(intent, REQUEST_CODE_SET_DEFAULT_ASSISTANT);
                result.success(null);
            } else {
                result.error("UNAVAILABLE", "RoleManager API is not available.", null);
            }
        } else {
            result.notImplemented();
        }
    }

    // Handle the result in onActivityResult()
} */
