import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:matrix/matrix.dart';

class AuthService {
  static Future<bool> authenticateUser() async {
    final localAuth = LocalAuthentication();
    bool isAuthenticated = false;

    try {
      isAuthenticated = await localAuth.authenticate(
        localizedReason: '.',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException catch (e) {
      Logs().e('Authentication error: $e');
    }

    if (isAuthenticated) {
      // Authenticated
      return true;
    } else {
      // Not authenticated
      return false;
    }
  }
}

class MatrixAuthService extends ChangeNotifier {
  String? error;
  Client? client;
  Future<Client?> login(
    MatrixState? matrix,
    AuthenticationIdentifier? identifier,
    String? password,
  ) async {
    try {
      await matrix!.getLoginClient().login(
            LoginType.mLoginPassword,
            identifier: identifier,
            password: password,
            initialDeviceDisplayName: PlatformInfos.clientName,
          );
      notifyListeners();
      return client;
    } on MatrixException catch (exception) {
      error = exception.errorMessage;
      notifyListeners();
      return null;
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
      return null;
    }
  }
}
