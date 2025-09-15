part of 'app_bloc.dart';

@immutable
sealed class AppEvent {
  const AppEvent();
}

class LoginRequested extends AppEvent {
  final String username;
  final String password;
  final String? deviceId;

  const LoginRequested({
    required this.username,
    required this.password,
    this.deviceId,
  });

  List<Object?> get props => [username, password, deviceId];
}

final class _AppUserChanged extends AppEvent {
  const _AppUserChanged(this.user);

  final User user;
}

final class AppStarted extends AppEvent {
  const AppStarted();
}
