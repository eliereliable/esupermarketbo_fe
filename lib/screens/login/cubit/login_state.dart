part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {}

final class LoginOtpRequired extends LoginState {
  final String deviceId;
  final DateTime otpExpiresUtc;
  final String email;

  const LoginOtpRequired({
    required this.deviceId,
    required this.otpExpiresUtc,
    required this.email,
  });

  @override
  List<Object> get props => [deviceId, otpExpiresUtc, email];
}

final class LoginError extends LoginState {
  final String message;

  const LoginError({required this.message});

  @override
  List<Object> get props => [message];
}
