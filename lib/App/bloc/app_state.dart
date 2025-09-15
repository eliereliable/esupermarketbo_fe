part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
  initial,
}

class AppState extends Equatable {
  const AppState._({
    required this.status,
    this.user,
    this.email
  });
  const AppState.initial() : this._(status: AppStatus.initial);

  const AppState.authenticated(Models.User user)
      : this._(status: AppStatus.authenticated, user: user);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);




  final AppStatus status;
  final Models.User? user;
  final String? email;


  @override
  List<Object?> get props => [status, user, email];
}