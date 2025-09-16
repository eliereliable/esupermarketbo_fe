import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';

import 'two_factor_state.dart';

class TwoFactorCubit extends Cubit<TwoFactorState> {
  final AuthenticationRepository _authRepository;
  Timer? _timer;

  TwoFactorCubit({required AuthenticationRepository authenticationRepository})
    : _authRepository = authenticationRepository,
      super(const TwoFactorState());

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void initializeTimer(DateTime otpExpiresUtc) {
    final now = DateTime.now().toUtc();
    final expiry = otpExpiresUtc.toUtc();
    final diff = expiry.difference(now);
    final initial = diff.inSeconds > 0 && diff.inSeconds <= 60
        ? Duration(seconds: diff.inSeconds)
        : const Duration(seconds: 60);

    _timer?.cancel();
    emit(state.copyWith(remaining: initial, canResend: initial.inSeconds <= 0));

    if (initial.inSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final seconds = state.remaining.inSeconds - 1;
      if (seconds <= 0) {
        emit(state.copyWith(remaining: Duration.zero, canResend: true));
        _timer?.cancel();
      } else {
        emit(state.copyWith(remaining: Duration(seconds: seconds)));
      }
    });
  }

  Future<void> resend({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    if (!state.canResend || state.verifying) return;
    try {
      await _authRepository.loginWithUsernameAndPassword(
        username: username,
        password: password,
        deviceId: deviceId,
      );
      emit(
        state.copyWith(
          canResend: false,
          remaining: const Duration(seconds: 60),
        ),
      );
      _timer?.cancel();
      _timer = null;
      initializeTimer(DateTime.now().toUtc().add(const Duration(seconds: 60)));
      emit(state.copyWith(message: 'Verification code resent'));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to resend: $e'));
    }
  }

  Future<void> verify({
    required String otp,
    required String deviceId,
    required String email,
    required bool trust,
  }) async {
    if (state.verifying) return;
    emit(state.copyWith(verifying: true, error: null, message: null));
    try {
      await _authRepository.verifyOtp(
        otp: otp,
        deviceId: deviceId,
        email: email,
        trust: trust,
      );
      emit(state.copyWith(verifying: false, success: true));
    } catch (e) {
      emit(state.copyWith(verifying: false, error: 'Verification failed: $e'));
    }
  }
}
