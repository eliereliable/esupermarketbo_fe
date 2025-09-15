import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? email;
  final int? userId;
  final String? userName;
  final String? displayName;
  final String? accessToken;
  final DateTime? accessTokenExpiresUtc;
  final String? refreshToken;
  final DateTime? refreshTokenExpiresUtc;
  final String? tokenType;
  final String? error;
  final int? userTypeId;
  final bool hasError;
  final String? deviceId;

  const User({
    this.email,
    this.userId,
    this.userName,
    this.displayName,
    this.accessToken,
    this.accessTokenExpiresUtc,
    this.refreshToken,
    this.refreshTokenExpiresUtc,
    this.tokenType,
    this.error = '',
    this.userTypeId,
    this.hasError = false,
    this.deviceId,
  });

  /// Factory constructor for creating a `User` from JSON.
  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      accessToken: json['access_token'] as String?,
      accessTokenExpiresUtc: json['access_token_expires_utc']  != null
            ? DateTime.tryParse(json['access_token_expires_utc']) // Convert to DateTime
            : null,
      refreshToken: json['refresh_token'] as String?,
      refreshTokenExpiresUtc: json['refresh_token_expires_utc']  != null
            ? DateTime.tryParse(json['refresh_token_expires_utc']) // Convert to DateTime
            : null,
      tokenType: json['token_type'] as String?,
      userId: json['user_id'] as int,
      email: json['email'] as String?,
      userName: json['username'] as String?,
      deviceId: json['device_id'] as String?,
      displayName: json['display_name'] as String?,
      userTypeId: json['user_type_id'] as int?,
      
    );
  }

  /// Factory constructor for handling errors.
  factory User.withError(
    String errorValue, {
    String? email,
    int? userId = 0,
    String? userName,
    String? displayName,
    String? accessToken,
    DateTime? accessTokenExpiresUtc,
    String? refreshToken,
    DateTime? refreshTokenExpiresUtc,
    String? tokenType,
    String? deviceId,
    int? userTypeId,
    bool? hasError,
   
  }) {
    return User(
      email: email,
      userId: userId,
      userName: userName,
      displayName: displayName,
      accessToken: accessToken,
      accessTokenExpiresUtc: accessTokenExpiresUtc,
      refreshToken: refreshToken,
      refreshTokenExpiresUtc: refreshTokenExpiresUtc,
      tokenType: tokenType,
      deviceId: deviceId,
      userTypeId: userTypeId,
      hasError: hasError ?? false,
      error: errorValue,
    );
  }

  /// Convert the `User` object to JSON.
  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'access_token_expires_utc': accessTokenExpiresUtc?.toIso8601String(),
    'refresh_token': refreshToken,
    'refresh_token_expires_utc': refreshTokenExpiresUtc?.toIso8601String(),
    'token_type': tokenType,
    'user_id': userId,
    'email': email,
    'username': userName,
    'device_id': deviceId,
    'display_name': displayName,
    'user_type_id': userTypeId,
  
  };

  /// Empty user instance.
  static const empty = User(
    userId: 0,
    userName: '',
    email: '',
    displayName: '',
    accessToken: '',
    accessTokenExpiresUtc: null,
    refreshToken: '',
    refreshTokenExpiresUtc: null,
    tokenType: '',
    deviceId: '',
    userTypeId: 0,
    hasError: false,
    error: '',
  );

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  /// Allows copying the `User` object with modified values.
  User copyWith({
    int? userId,
    String? userName,
    String? displayName,
    String? email,
   String? accessToken,
   DateTime? accessTokenExpiresUtc,
   String? refreshToken,
   DateTime? refreshTokenExpiresUtc,
   String? tokenType,
   String? deviceId,
   int? userTypeId,
   bool? hasError,
   String? error,
  }) {
    return User(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiresUtc: accessTokenExpiresUtc ?? this.accessTokenExpiresUtc,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiresUtc: refreshTokenExpiresUtc ?? this.refreshTokenExpiresUtc,
      tokenType: tokenType ?? this.tokenType,
      deviceId: deviceId ?? this.deviceId,
      userTypeId: userTypeId ?? this.userTypeId,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props => [
   accessToken,
   accessTokenExpiresUtc,
   refreshToken,
   refreshTokenExpiresUtc,
   tokenType,
   deviceId,
   userTypeId,
   displayName,
   userId,
   userName,
   email
  ];
}
