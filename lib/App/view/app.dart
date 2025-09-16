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
          return appBloc;
        },
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  static final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        final nav = _navKey.currentState;
        if (nav == null) return;
        if (state.status == AppStatus.authenticated) {
          nav.pushNamedAndRemoveUntil('/home', (route) => false);
        } else if (state.status == AppStatus.unauthenticated) {
          nav.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final themeManager = ThemeManager();
          return MaterialApp(
            navigatorKey: _navKey,
            title: 'ESuperMarket',
            theme: themeManager.getThemeData(ThemeType.LightMode, null),
            themeMode: ThemeMode.light,
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
                    username: args['username'] as String?,
                    password: args['password'] as String?,
                  );
                }
                // Fallback: attempt to restore from storage on refresh
                return const _TwoFactorLoader();
              },
            },
            // Provide a minimal placeholder; navigation listener will drive actual route
            home: state.status == AppStatus.authenticated
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
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
