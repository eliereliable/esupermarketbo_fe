import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:esupermarketbo_fe/App/view/app.dart';
import 'package:esupermarketbo_fe/App/view/bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
   Bloc.observer = AppBlocObserver();
  final authenticationRepository = AuthenticationRepository(
    authenticationMethod: AuthenticationMethods.JWT,
  );
  await authenticationRepository.initialize();
  runApp(MyApp(authenticationRepository: authenticationRepository));
}

class MyApp extends StatelessWidget {
  final AuthenticationRepository authenticationRepository;
  const MyApp({required this.authenticationRepository, super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return App(authenticationRepository: authenticationRepository);
  }
}
