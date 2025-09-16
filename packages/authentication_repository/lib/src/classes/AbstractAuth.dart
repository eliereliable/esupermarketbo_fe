import 'package:authentication_repository/src/models/models.dart' as Models;

abstract class AbstractAuth {
  Future<dynamic> loginWithUserNameAndPassword({
    required String userName,
    required String password,
    String? deviceId,
  });

  Future<dynamic> refreshToken({
    required String refreshToken,
    required String deviceId,
  });

  Future<dynamic> verifyOtp({
    required String otp,
    required String deviceId,
    required String email,
    required bool trust,
  });

  Future<dynamic> logout({
    required String refreshToken,
    required String deviceId,
  });

  Models.User? get currentUser;
  Stream<Models.User> get user;
}
