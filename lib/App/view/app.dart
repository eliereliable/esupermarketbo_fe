import 'package:authentication_repository/authentication_repository.dart';
import 'package:esupermarketbo_fe/App/bloc/app_bloc.dart';
import 'package:esupermarketbo_fe/ThemeManager/theme_mnager.dart';
import 'package:esupermarketbo_fe/screens/home_page.dart';
import 'package:esupermarketbo_fe/screens/login/view/login_page.dart';
import 'package:esupermarketbo_fe/screens/two_factor/view/two_factor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as FSS;

class App extends StatelessWidget {
  final AuthenticationRepository _authenticationRepository;
  const App({
    required AuthenticationRepository authenticationRepository,
    super.key,
  }) : _authenticationRepository = authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider<AppBloc>(
        create: (_) {
          final appBloc = AppBloc(
            authenticationRepository: _authenticationRepository,
          );
          // Dynamic localization service is now initialized in AppBloc._initialize()
          return appBloc;
        },
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final themeManager = ThemeManager();
        return MaterialApp(
          title: 'ESuperMarket',
          theme: themeManager.getThemeData(ThemeType.LightMode, null),
          themeMode: ThemeMode.light,
          initialRoute: _getInitialRoute(state),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/two-factor': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              if (args != null) {
                return TwoFactorScreen(
                  deviceId: args['deviceId'] as String,
                  otpExpiresUtc: args['otpExpiresUtc'] as DateTime,
                  email: args['email'] as String,
                );
              }
              // Fallback: attempt to restore from storage on refresh
              return const _TwoFactorLoader();
            },
          },
          home: () {
            // if (state.status == AppStatus.authenticated) {
            //   return const HomeScreen();
            // } else if (state.status == AppStatus.unauthenticated) {
            //   return const LoginScreen();
            // }
            // return const LoginScreen(); // Default fallback
          }(),
        );
      },
    );
  }

  String _getInitialRoute(AppState state) {
    if (state.status == AppStatus.authenticated) {
      return '/home';
    } else if (state.status == AppStatus.unauthenticated) {
      return '/login';
    }
    return '/login'; // Default fallback
  }
}

class _TwoFactorLoader extends StatefulWidget {
  const _TwoFactorLoader();

  @override
  State<_TwoFactorLoader> createState() => _TwoFactorLoaderState();
}

class _TwoFactorLoaderState extends State<_TwoFactorLoader> {
  final FSS.FlutterSecureStorage _secureStorage =
      const FSS.FlutterSecureStorage();
  Future<Map<String, dynamic>?>? _load;

  @override
  void initState() {
    super.initState();
    _load = _loadFromStorage();
  }

  Future<Map<String, dynamic>?> _loadFromStorage() async {
    final deviceId = await _secureStorage.read(key: 'device_token');
    final email = await _secureStorage.read(key: 'otp_email');
    final otpExpiry = await _secureStorage.read(key: 'otp_expires_utc');
    if (deviceId != null && email != null && otpExpiry != null) {
      return {
        'deviceId': deviceId,
        'email': email,
        'otpExpiresUtc': DateTime.tryParse(otpExpiry) ?? DateTime.now(),
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          // Nothing to restore -> go to login
          return const LoginScreen();
        }
        return TwoFactorScreen(
          deviceId: data['deviceId'] as String,
          otpExpiresUtc: data['otpExpiresUtc'] as DateTime,
          email: data['email'] as String,
        );
      },
    );
  }
}
