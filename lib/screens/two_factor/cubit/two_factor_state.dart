import 'package:equatable/equatable.dart';

class TwoFactorState extends Equatable {
  final Duration remaining;
  final bool canResend;
  final bool verifying;
  final bool success;
  final String? error;
  final String? message;

  const TwoFactorState({
    this.remaining = const Duration(seconds: 60),
    this.canResend = false,
    this.verifying = false,
    this.success = false,
    this.error,
    this.message,
  });

  TwoFactorState copyWith({
    Duration? remaining,
    bool? canResend,
    bool? verifying,
    bool? success,
    String? error,
    String? message,
  }) {
    return TwoFactorState(
      remaining: remaining ?? this.remaining,
      canResend: canResend ?? this.canResend,
      verifying: verifying ?? this.verifying,
      success: success ?? this.success,
      error: error,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    remaining,
    canResend,
    verifying,
    success,
    error,
    message,
  ];
}
