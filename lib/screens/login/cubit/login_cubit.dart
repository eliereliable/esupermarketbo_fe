import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:authentication_repository/authentication_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authenticationRepository;

  LoginCubit({required AuthenticationRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository,
      super(LoginInitial());

  Future<void> login({
    required String username,
    required String password,
    String? deviceId,
  }) async {
    emit(LoginLoading());

    try {
      final response = await _authenticationRepository
          .loginWithUsernameAndPassword(
            username: username,
            password: password,
            deviceId: deviceId,
          );

      // Handle different response codes
      if (response is Map<String, dynamic>) {
        // Check if this is an OTP required response (202)
        if (response['messages'] != null &&
            (response['messages'] as List).contains('otp_required')) {
          final extra = response['extra'] as Map<String, dynamic>;
          emit(
            LoginOtpRequired(
              deviceId: extra['device_id'] as String,
              otpExpiresUtc: DateTime.parse(extra['otp_expires_utc'] as String),
              email: extra['email'] as String,
            ),
          );
        } else {
          // Successful login (200)
          emit(LoginSuccess());
        }
      } else {
        // Successful login (200) - user data response
        emit(LoginSuccess());
      }
    } catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }
}
