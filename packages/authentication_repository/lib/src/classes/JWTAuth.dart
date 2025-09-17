import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:authentication_repository/src/authentication_repository.dart';
import 'package:authentication_repository/src/classes/AbstractAuth.dart';

import 'package:authentication_repository/src/models/models.dart' as Models;

import 'package:authentication_repository/src/utils/network_utils.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as FSS;

class URLS {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:7010/api/"; // Android emulator
    } else if (Platform.isIOS) {
      return "http://localhost:7010/api/"; // iOS simulator
    } else {
      return "http://localhost:7010/api/"; // Web/Desktop
    }
  }

  static String get verifyOtpUrl => "${baseUrl}Auth/login/verify";
  static String get logoutUrl => "${baseUrl}Auth/logout";
  static String get loginUrl => "${baseUrl}Auth/login";
  static String get refreshUrl => "${baseUrl}Auth/refresh";
}

class JWTAuth implements AbstractAuth {
  String apiVersion = "v1";

  final FSS.FlutterSecureStorage _secureStorage =
      const FSS.FlutterSecureStorage();
  late final NetworkUtil _networkUtil;

  final _controller = StreamController<Models.User>.broadcast();
  Models.User? _currentUser;
  Future<void>? initialization;
  @override
  Stream<Models.User> get user {
    return _controller.stream.map((Models.User userResponse) {
      return userResponse;
    });
  }

  JWTAuth(AuthenticationRepository authRepository) {
    _networkUtil = NetworkUtil(authRepository: authRepository);
    initialization = _initialize();
  }

  Future<void> _initialize() async {
    final token = await _secureStorage.read(key: "jwt_token");
    final userDataString = await _secureStorage.read(key: "user_data");

    if (token != null && userDataString != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataString);
      Models.User userResponse = Models.User.fromJson(userData, token);
      if (userResponse.accessTokenExpiresUtc != null) {
        DateTime now = DateTime.now();
        if (now.isAfter(userResponse.accessTokenExpiresUtc!)) {
          // Guard: only attempt refresh if we have required data
          final deviceId = userResponse.deviceId ?? "";
          final rToken = userResponse.refreshToken ?? "";
          if (deviceId.isNotEmpty && rToken.isNotEmpty) {
            await refreshToken(deviceId: deviceId, refreshToken: rToken);
          } else {
            // Clear to unauthenticated state
            await _secureStorage.delete(key: "jwt_token");
            await _secureStorage.delete(key: "user_data");
            _controller.sink.add(Models.User.empty);
            _currentUser = null;
          }
        } else {
          _controller.sink.add(userResponse);
          _currentUser = userResponse;
        }
      }
    } else {
      _controller.sink.add(Models.User.empty);
    }
  }

  closeStream() {
    _controller.close();
  }

  @override
  Future loginWithUserNameAndPassword({
    required String userName,
    required String password,
    String? deviceId,
  }) async {
    final deviceIdStorage = await _secureStorage.read(key: "device_token");
    log("deviceIdStorage is $deviceIdStorage");
    try {
      final response = await _networkUtil.post(
        URLS.loginUrl,
        headers: {'Content-Type': 'application/json'},
        data: {
          "username": userName,
          "password": password,
          if (deviceIdStorage != null) "device_id": deviceIdStorage,
        },
      );

      if (response != null) {
        log("here response $response");

        // The network layer already json-decodes responses (including 202)
        if (response is Map<String, dynamic>) {
          // Check for OTP-required flow (202)
          if (response['messages'] != null &&
              response['messages'] is List &&
              (response['messages'] as List).contains('otp_required')) {
            final extra = response['extra'] as Map<String, dynamic>?;
            final String? extraDeviceId = extra != null
                ? extra['device_id'] as String?
                : null;
            final String? extraEmail = extra != null
                ? extra['email'] as String?
                : null;
            final String? extraOtpExpiresUtc = extra != null
                ? extra['otp_expires_utc'] as String?
                : null;

            // Don't add temporary user to stream for OTP required responses
            // This prevents AppBloc from navigating to home when 2FA is required
            // The LoginCubit will handle navigation to two-factor page

            // Persist OTP context for web refresh
            if (extraDeviceId != null && extraDeviceId.isNotEmpty) {
              await _secureStorage.write(
                key: "device_token",
                value: extraDeviceId,
              );
            }
            if (extraEmail != null && extraEmail.isNotEmpty) {
              await _secureStorage.write(key: "otp_email", value: extraEmail);
            }
            if (extraOtpExpiresUtc != null && extraOtpExpiresUtc.isNotEmpty) {
              await _secureStorage.write(
                key: "otp_expires_utc",
                value: extraOtpExpiresUtc,
              );
            }

            return response; // Let caller handle navigation to 2FA
          }

          // Otherwise assume successful login (200) with user payload
          final Map<String, dynamic> userData = response;
          Models.User userResponse = Models.User.fromJson(
            userData,
            userData['access_token'] as String? ?? "",
          );
          log("here user $userResponse");
          _controller.sink.add(userResponse);
          _currentUser = userResponse;

          // Store user data and token
          await _secureStorage.write(
            key: "jwt_token",
            value: userResponse.accessToken,
          );
          await _secureStorage.write(
            key: "user_data",
            value: jsonEncode(userData),
          );
          if (userResponse.deviceId != null) {
            await _secureStorage.write(
              key: "device_token",
              value: userResponse.deviceId,
            );
          }

          return userData;
        } else if (response is String) {
          // Fallback: string body (should not happen with current NetworkUtil)
          final Map<String, dynamic> userData = jsonDecode(response);
          Models.User userResponse = Models.User.fromJson(
            userData,
            userData['access_token'] as String? ?? "",
          );
          _controller.sink.add(userResponse);
          _currentUser = userResponse;

          await _secureStorage.write(
            key: "jwt_token",
            value: userResponse.accessToken,
          );
          await _secureStorage.write(
            key: "user_data",
            value: jsonEncode(userData),
          );
          if (userResponse.deviceId != null) {
            await _secureStorage.write(
              key: "device_token",
              value: userResponse.deviceId,
            );
          }
          return userData;
        } else {
          _controller.sink.add(Models.User.empty);
          return null;
        }
      } else {
        _controller.sink.add(Models.User.empty);
        return null;
      }
    } catch (e) {
      String errorMessage = e.toString();
      log("error is $errorMessage");
    }
  }

  @override
  Future verifyOtp({
    required String otp,
    required String deviceId,
    required String email,
    required bool trust,
  }) async {
    try {
      final response = await _networkUtil.post(
        URLS.verifyOtpUrl,
        headers: {'Content-Type': 'application/json'},
        data: {
          "otp": otp,
          "deviceId": deviceId,
          "email": email,
          "trust": trust,
        },
      );

      if (response is Map<String, dynamic>) {
        // Build user from successful verification response
        final Map<String, dynamic> userData = response;
        final Models.User userResponse = Models.User.fromJson(
          userData,
          userData['access_token'] as String? ?? "",
        );
        log(
          'JWTAuth: verifyOtp success - adding user to stream: $userResponse',
        );
        _controller.sink.add(userResponse);
        _currentUser = userResponse;

        // Persist tokens and user data
        await _secureStorage.write(
          key: "jwt_token",
          value: userResponse.accessToken,
        );
        await _secureStorage.write(
          key: "user_data",
          value: jsonEncode(userData),
        );
        await _secureStorage.write(
          key: "device_token",
          value: jsonEncode(userData),
        );
        if (userResponse.deviceId != null &&
            userResponse.deviceId!.isNotEmpty) {
          await _secureStorage.write(
            key: "device_token",
            value: userResponse.deviceId,
          );
        }

        // Clear temporary OTP context
        await _secureStorage.delete(key: "otp_email");
        await _secureStorage.delete(key: "otp_expires_utc");

        return userData;
      }
      return null;
    } catch (e) {
      log("verifyOtp error: $e");
      rethrow;
    }
  }

  @override
  Future refreshToken({
    required String refreshToken,
    required String deviceId,
  }) async {
    try {
      final response = await _networkUtil.post(
        URLS.refreshUrl,
        headers: {'Content-Type': 'application/json'},
        data: {'refresh_token': refreshToken, 'device_id': deviceId},
      );

      if (response is Map<String, dynamic>) {
        final Map<String, dynamic> userData = response;
        final Models.User userResponse = Models.User.fromJson(
          userData,
          userData['access_token'] as String? ?? "",
        );
        _controller.sink.add(userResponse);
        _currentUser = userResponse;

        await _secureStorage.write(
          key: "jwt_token",
          value: userResponse.accessToken,
        );
        await _secureStorage.write(
          key: "user_data",
          value: jsonEncode(userData),
        );
        if (userResponse.deviceId != null &&
            userResponse.deviceId!.isNotEmpty) {
          await _secureStorage.write(
            key: "device_token",
            value: userResponse.deviceId,
          );
        }

        return userData;
      }

      // Unexpected response shape: clear auth
      await _secureStorage.delete(key: "jwt_token");
      await _secureStorage.delete(key: "user_data");
      _currentUser = null;
      _controller.sink.add(Models.User.empty);
      return null;
    } catch (e) {
      log("refreshToken error: $e");
      // On failure, clear auth
      await _secureStorage.delete(key: "jwt_token");
      await _secureStorage.delete(key: "user_data");
      _currentUser = null;
      _controller.sink.add(Models.User.empty);
      rethrow;
    }
  }

  @override
  Models.User? get currentUser {
    return _currentUser;
  }

  @override
  Future logout() async {
    await _secureStorage.delete(key: "jwt_token");
    await _secureStorage.delete(key: "user_data");
    // await _secureStorage.delete(key: "device_token");
    await _secureStorage.delete(key: "otp_email");
    await _secureStorage.delete(key: "otp_expires_utc");

    _currentUser = null;
    _controller.sink.add(Models.User.empty);
  }
}
