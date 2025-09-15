import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthenticationRepository>();
    final user = authRepo.currentUser;
    final displayName = user?.displayName?.trim();

    return Scaffold(
      body: Center(
        child: Text(
          displayName != null && displayName.isNotEmpty
              ? 'Welcome, $displayName'
              : 'Welcome',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
