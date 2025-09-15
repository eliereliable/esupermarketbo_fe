import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication_repository/src/authentication_repository.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class NetworkUtil {
  static NetworkUtil? _instance;
  final AuthenticationRepository _authRepository;

  NetworkUtil.internal({required AuthenticationRepository authRepository})
    : _authRepository = authRepository;

  factory NetworkUtil({required AuthenticationRepository authRepository}) {
    return NetworkUtil.internal(authRepository: authRepository);
  }

  Future<String?> _ensureValidToken() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null || currentUser.accessToken == null) {
      return null; // No valid token
    }

    final tokenExpiryDate = currentUser.accessTokenExpiresUtc;
    final now = DateTime.now();

    if (tokenExpiryDate != null && now.isAfter(tokenExpiryDate)) {
      // Trigger the refresh process.
      await _authRepository.refreshToken(
        refreshToken: currentUser.refreshToken ?? "",
        deviceId: currentUser.deviceId ?? "",
      );
      // After refreshing, get the updated token from currentUser.
      final updatedUser = _authRepository.currentUser;

      return updatedUser?.accessToken;
    }

    return currentUser.accessToken;
  }

  Future<Uint8List> getBytesWithCheckToken(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    // Ensure token is valid
    final token = await _ensureValidToken();
    if (token == null) {
      throw UnauthorisedExceptions("Authentication required");
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';
    headers['Accept'] = 'application/octet-stream'; // or application/pdf

    var uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes; // ✅ Return raw bytes directly
    } else {
      // Optionally throw more specific errors
      throw FetchDataExceptions(
        'Failed to fetch binary data. Status code: ${response.statusCode}',
      );
    }
  }

  Future<dynamic> getWithCheckToken(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    var responseJson;

    // Ensure token is valid
    final token = await _ensureValidToken();
    if (token == null) {
      throw UnauthorisedExceptions("Authentication required");
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';

    var uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    final response = await http.get(uri, headers: headers);
    responseJson = _returnResponse(response);
    return responseJson;
  }

  Future<dynamic> postWithCheckToken(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    var responseJson;

    // Ensure token is valid
    final token = await _ensureValidToken();
    if (token == null) {
      throw UnauthorisedExceptions("Authentication required");
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    responseJson = _returnResponse(response);
    return responseJson;
  }

  Future<dynamic> postMultiWithCheckToken({
    required String url,
    required List<File> documents,
    required List<Map<String, dynamic>> metadata,
  }) async {
    final token = await _ensureValidToken();
    if (token == null) {
      throw UnauthorisedExceptions("Authentication required");
    }

    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    // Set headers exactly as in Postman
    request.headers.addAll({
      'accept': 'text/plain',
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    });

    // Add the first file only as 'documents' (singular)
    if (documents.isNotEmpty) {
      final file = documents[0];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'documents',
        stream,
        length,
        filename: basename(file.path),
      );
      request.files.add(multipartFile);
    }

    // Add metadata exactly as in Postman
    if (metadata.isNotEmpty) {
      request.fields['metadata'] = jsonEncode(metadata[0]);
    }

    if (request.files.isNotEmpty) {}

    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();
    final response = http.Response(responseString, streamedResponse.statusCode);

    return _returnResponse(response);
  }

  Future<dynamic> putWithCheckToken(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    var responseJson;

    // Ensure token is valid
    final token = await _ensureValidToken();
    if (token == null) {
      throw UnauthorisedExceptions("Authentication required");
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    responseJson = _returnResponse(response);
    return responseJson;
  }

  Future<dynamic> deleteWithCheckToken(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    var responseJson;

    // Ensure token is valid
    final token = await _ensureValidToken();
    if (token == null) {
      throw UnauthorisedExceptions("Authentication required");
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    responseJson = _returnResponse(response);
    return responseJson;
  }

  Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    var responseJson;

    var uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    final response = await http.get(uri, headers: headers);
    responseJson = _returnResponse(response);

    if (response.statusCode == 200) {
      responseJson = _returnResponse(response);
    } else {
      responseJson = _returnResponse(response);
    }
    return responseJson;
  }

  Future<dynamic> post(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    var responseJson;

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      log("here entered");
      responseJson = _returnResponse(response);
    } else {
      log("here entered 1");
      responseJson = _returnResponse(response);
    }
    return responseJson;
  }

  Future<dynamic> postMulti(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? data,
    File? files,
  }) async {
    var responseJson;

    var uri = Uri.parse(url);

    var request = http.MultipartRequest('POST', uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (data != null) {
      request.fields.addAll(data);
    }
    if (files != null) {
      var stream = http.ByteStream(files.openRead());
      var length = await files.length();
      var multipartFile = http.MultipartFile(
        'Files',
        stream,
        length,
        filename: basename(files.path),
      );
      request.files.add(multipartFile);
    }
    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      responseJson = _returnResponse(
        http.Response(responseString, response.statusCode),
      );
    } else {
      responseJson = _returnResponse(
        http.Response(responseString, response.statusCode),
      );
    }

    return responseJson;
  }

  Future<dynamic> put(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    var responseJson;

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      responseJson = _returnResponse(response);
    } else {
      responseJson = _returnResponse(response);
    }
    return responseJson;
  }

  Future<dynamic> putMulti(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? data,
    File? files,
  }) async {
    var responseJson;

    var uri = Uri.parse(url);

    var request = http.MultipartRequest('PUT', uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (data != null) {
      request.fields.addAll(data);
    }
    if (files != null) {
      var stream = http.ByteStream(files.openRead());
      var length = await files.length();
      var multipartFile = http.MultipartFile(
        'Files',
        stream,
        length,
        filename: basename(files.path),
      );
      request.files.add(multipartFile);
    }
    var response = await request.send();
    var responseString = await response.stream.bytesToString();

    responseJson = _returnResponse(
      http.Response(responseString, response.statusCode),
    );

    return responseJson;
  }

  Future<dynamic> delete(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    var responseJson;

    final response = await http
        .delete(Uri.parse(url), headers: headers, body: json.encode(data))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      responseJson = _returnResponse(response);
    } else {
      responseJson = _returnResponse(response);
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202: // Add 202 for OTP required responses
      case 204:
        return json.decode(response.body);
      case 400:
      case 409:
        var decodedResponse = json.decode(response.body);
        String errorMessages = "Validation errors occurred: ";

        if (decodedResponse is List) {
          errorMessages += decodedResponse.join(", ");
        } else if (decodedResponse is Map) {
          decodedResponse.forEach((key, value) {
            errorMessages += "\n$key: ${value.join(", ")}";
          });
        }

        throw BadRequestExceptions(errorMessages);
      case 401:
      case 403:
        throw UnauthorisedExceptions(
          json.decode(response.body).toString() ?? "401 Unauthorized",
        );
      case 422:
        throw InvalidInputExceptions(json.decode(response.body).toString());
      case 404:
      case 423:
        throw NotFoundExceptions(json.decode(response.body).toString());
      case 500:
      default:
        throw FetchDataExceptions(
          'Error occurred while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }

  void handleResponseError(dynamic ex) {
    if (ex.response != null &&
        ex.response.data != null &&
        ex.response.data['message'] != null) {
      throw _returnResponse(ex.response);
    } else {
      throw Exception(ex.message);
    }
  }
}

class FetchDataExceptions implements Exception {
  final String message;
  FetchDataExceptions(this.message);
}

class BadRequestExceptions implements Exception {
  final String message;
  BadRequestExceptions(this.message);
}

class NotFoundExceptions implements Exception {
  final String message;
  NotFoundExceptions(this.message);
}

class UnauthorisedExceptions implements Exception {
  final String message;
  UnauthorisedExceptions(this.message);
}

class InvalidInputExceptions implements Exception {
  final String message;
  InvalidInputExceptions(this.message);
}
