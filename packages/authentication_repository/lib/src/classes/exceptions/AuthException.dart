class AuthException implements Exception {
  final message;
  final prefix;
  AuthException([this.message, this.prefix]);

  String toString() {
    return "$prefix$message";
  }
}


class FetchDataException extends AuthException {
  FetchDataException([String? message])
      : super(message, "Connection Error: ");
}

class BadRequestException extends AuthException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AuthException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AuthException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}
class NotFoundException extends AuthException {
  NotFoundException([String? message]) : super(message, " Not Found Api Error 404");
}

class LogInWithEmailAndPasswordFailure extends AuthException {
  LogInWithEmailAndPasswordFailure([String? message]) : super(message, "Invalid Login: ");
}

class LogoutFailure extends AuthException {
  LogoutFailure([String? message]) : super(message, "Logout Failure: ");
}
