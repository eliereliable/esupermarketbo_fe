

import 'dart:async';

import 'package:authentication_repository/src/classes/AbstractAuth.dart';
import 'package:authentication_repository/src/classes/JWTAuth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/models.dart';

enum AuthenticationMethods {JWT}

class AuthenticationRepository {
  final AuthenticationMethods authenticationMethod;
  static AbstractAuth? _authPortal;
  final _controller = StreamController<User>();

    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthenticationRepository(
      {this.authenticationMethod = AuthenticationMethods.JWT}) {
    switch (authenticationMethod) {
      case AuthenticationMethods.JWT:
        _authPortal = JWTAuth(this);
        break;
    }
  }
  Future<void> initialize() async {
    if (_authPortal is JWTAuth) {
      await (_authPortal as JWTAuth).initialization;
    }
  }

  Stream<User> get user {
    return _controller.stream.map((User user) {
      return user;
    });
  }

  Stream<User>? get userResponse {
    return _authPortal!.user;
  }

  User? get currentUser {
    return _authPortal?.currentUser;
  }
  Future<dynamic> loginWithUsernameAndPassword(
      {required String username, required String password , String? deviceId}) async {
    return await _authPortal!
        .loginWithUserNameAndPassword(userName: username, password: password, deviceId: deviceId);
  }
  Future<dynamic> refreshToken(
      {required String refreshToken, required String deviceId}) async {
    return await _authPortal!
        .refreshToken(refreshToken: refreshToken, deviceId: deviceId);
  }
}
