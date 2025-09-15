import 'package:flutter/material.dart';

class TwoFactorScreen extends StatefulWidget {
  final String deviceId;
  final DateTime otpExpiresUtc;
  final String email;

  const TwoFactorScreen({
    super.key,
    required this.deviceId,
    required this.otpExpiresUtc,
    required this.email,
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                const Icon(Icons.security, size: 80, color: Colors.blue),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Enter Verification Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'ve sent a verification code to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // OTP Field
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    hintText: 'Enter 6-digit code',
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, letterSpacing: 2),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Verification code is required';
                    }
                    if (value.length != 6) {
                      return 'Verification code must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Verify Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement OTP verification
                      _verifyOtp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend Code Button
                TextButton(
                  onPressed: () {
                    // TODO: Implement resend OTP
                    _resendOtp();
                  },
                  child: const Text('Resend Code'),
                ),

                const SizedBox(height: 24),

                // Expiry Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Code expires at ${_formatDateTime(widget.otpExpiresUtc)}',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOtp() {
    // TODO: Implement OTP verification logic
    // This would typically call an API to verify the OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP verification not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _resendOtp() {
    // TODO: Implement resend OTP logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resend OTP not yet implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
