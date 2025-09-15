import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/authentication_repository.dart'
    as Models;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:esupermarketbo_fe/ThemeManager/theme_mnager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as FSS;
import 'package:meta/meta.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<User>? _userSubscription;
  final FSS.FlutterSecureStorage _secureStorage =
      const FSS.FlutterSecureStorage();
  static ThemeManager themeManager = ThemeManager();

  AppBloc({required AuthenticationRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository,
      super(const AppState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<_AppUserChanged>(_onUserChanged);
    on<AppStarted>(_onAppStarted);
    add(const AppStarted());
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    await _authenticationRepository.initialize();

    if (_authenticationRepository.currentUser != null) {
      emit(AppState.authenticated(_authenticationRepository.currentUser!));
    } else {
      final userDataString = await _secureStorage.read(key: "user_data");
      if (userDataString != null) {
        emit(const AppState.initial());
      } else {
        emit(const AppState.unauthenticated());
      }
    }

    _userSubscription = _authenticationRepository.userResponse!.listen(
      (userResponse) => add(_AppUserChanged(userResponse)),
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    themeManager.configure(ThemeType.LightMode);
    if (event.user.isEmpty) {
      emit(const AppState.unauthenticated());
    } else {
      emit(AppState.authenticated(event.user));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AppState> emit) {
    _authenticationRepository.loginWithUsernameAndPassword(
      username: event.username,
      password: event.password,
      deviceId: event.deviceId,
    );
  }
}
