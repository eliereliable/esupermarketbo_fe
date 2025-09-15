import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  Timer? _timer;
  Duration _remaining = const Duration(seconds: 60);
  bool _canResend = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // If server-provided expiry is within 60s, use that; else fallback to 60s
    final now = DateTime.now().toUtc();
    final expiry = widget.otpExpiresUtc.toUtc();
    final diff = expiry.difference(now);
    _remaining = diff.inSeconds > 0 && diff.inSeconds <= 60
        ? Duration(seconds: diff.inSeconds)
        : const Duration(seconds: 60);

    _timer?.cancel();
    _canResend = _remaining.inSeconds <= 0;
    if (_canResend) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        setState(() {
          _remaining = Duration.zero;
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = (_remaining.inSeconds.remainder(
      60,
    )).toString().padLeft(2, '0');

    return Scaffold(
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security, size: 64, color: Colors.blue),
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
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _canResend
                          ? 'Code expired'
                          : 'Expires in $minutes:$seconds',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: _canResend ? Colors.red : Colors.orange.shade700,
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
                        enabled: !_verifying,
                        keyboardType: TextInputType.number,
                        onCompleted: (value) async {
                          if (value.length == 6) {
                            await _verifyOtpWithPrompt();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _verifying
                            ? null
                            : () async {
                                if ((_otpController.text).length == 6) {
                                  await _verifyOtpWithPrompt();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Enter 6-digit code'),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _verifying
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
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
                        onPressed: _canResend && !_verifying
                            ? _resendOtp
                            : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text('Resend Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtpWithPrompt() async {
    final otp = _otpController.text;
    if (otp.length != 6) return;

    final trust = await _askTrustDevice();
    if (!mounted) return;

    await _verifyOtp(trust: trust);
  }

  Future<bool> _askTrustDevice() async {
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

  Future<void> _verifyOtp({required bool trust}) async {
    setState(() {
      _verifying = true;
    });
    final auth = context.read<AuthenticationRepository>();
    try {
      await auth.verifyOtp(
        otp: _otpController.text,
        deviceId: widget.deviceId,
        email: widget.email,
        trust: trust,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _verifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    // Re-call login to trigger a new OTP
    final auth = context.read<AuthenticationRepository>();
    final username = widget.username;
    final password = widget.password;
    if (username == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing credentials to resend code')),
      );
      return;
    }

    try {
      await auth.loginWithUsernameAndPassword(
        username: username,
        password: password,
        deviceId: widget.deviceId,
      );
      // Restart timer after resend
      setState(() {
        _canResend = false;
        _remaining = const Duration(seconds: 60);
      });
      _startTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification code resent')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to resend: $e')));
    }
  }
}
