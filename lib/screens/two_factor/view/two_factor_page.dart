import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:esupermarketbo_fe/screens/two_factor/cubit/two_factor_cubit.dart';
import 'package:esupermarketbo_fe/screens/two_factor/cubit/two_factor_state.dart';

class TwoFactorScreen extends StatefulWidget {
  final String deviceId;
  final DateTime otpExpiresUtc;
  final String email;
  final String? username;
  final String? password;

  const TwoFactorScreen({
    super.key,
    required this.deviceId,
    required this.otpExpiresUtc,
    required this.email,
    this.username,
    this.password,
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TwoFactorCubit(
        authenticationRepository: context.read<AuthenticationRepository>(),
      )..initializeTimer(widget.otpExpiresUtc),
      child: BlocListener<TwoFactorCubit, TwoFactorState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.success) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Two-Factor Authentication'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocBuilder<TwoFactorCubit, TwoFactorState>(
                    builder: (context, state) {
                      final minutes = state.remaining.inMinutes
                          .remainder(60)
                          .toString()
                          .padLeft(2, '0');
                      final seconds = (state.remaining.inSeconds.remainder(
                        60,
                      )).toString().padLeft(2, '0');
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.security,
                            size: 64,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Enter Verification Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ve sent a verification code to\n${widget.email}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.canResend
                                ? 'Code expired'
                                : 'Expires in $minutes:$seconds',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: state.canResend
                                  ? Colors.red
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // OTP Pinput
                          Center(
                            child: Pinput(
                              controller: _otpController,
                              length: 6,
                              autofocus: true,
                              enabled: !state.verifying,
                              keyboardType: TextInputType.number,
                              onCompleted: (value) async {
                                if (value.length == 6) {
                                  await _verifyWithPrompt(context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: state.verifying
                                  ? null
                                  : () async {
                                      if ((_otpController.text).length == 6) {
                                        await _verifyWithPrompt(context);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Enter 6-digit code'),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state.verifying
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: state.canResend && !state.verifying
                                  ? () => context.read<TwoFactorCubit>().resend(
                                      username: widget.username ?? '',
                                      password: widget.password ?? '',
                                      deviceId: widget.deviceId,
                                    )
                                  : null,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: const Size(0, 32),
                              ),
                              child: const Text('Resend Code'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyWithPrompt(BuildContext context) async {
    final otp = _otpController.text;
    if (otp.length != 6) return;

    final trust = await _askTrustDevice(context);
    if (!mounted) return;

    await context.read<TwoFactorCubit>().verify(
      otp: otp,
      deviceId: widget.deviceId,
      email: widget.email,
      trust: trust,
    );
  }

  Future<bool> _askTrustDevice(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trust this device?'),
          content: const Text(
            'Do you want to trust this device for faster sign-in next time?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Trust'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
