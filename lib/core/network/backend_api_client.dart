import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/app_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around `http` for talking to OUR Flask backend
/// (auth / profile / favorites). Football data calls stay in
/// [FootballApiClient] and are untouched from v1.
///
/// Handles: auth header injection, one-shot refresh-and-retry on 401,
/// and turning Flask's `{error, field_errors}` JSON shape into
/// [ApiException] so UI code never touches raw HTTP.
class BackendApiClient {
  BackendApiClient._();
  static final BackendApiClient instance = BackendApiClient._();

  final String _base = ApiConstants.backendBaseUrl;

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) =>
      _send("GET", path, auth: auth);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) =>
      _send("POST", path, body: body, auth: auth);

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body, bool auth = true}) =>
      _send("PATCH", path, body: body, auth: auth);

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) =>
      _send("DELETE", path, auth: auth);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse("$_base$path");
    final headers = <String, String>{"Content-Type": "application/json"};

    if (auth) {
      final token = await SecureStorage.read(StorageKeys.accessToken);
      if (token != null) headers["Authorization"] = "Bearer $token";
    }

    http.Response response;
    try {
      response = await _request(method, uri, headers, body).timeout(ApiConstants.requestTimeout);
    } on SocketException {
      throw ApiException("No internet connection. Check your network and try again.");
    } on http.ClientException {
      throw ApiException("Couldn't reach the server. Please try again.");
    } catch (_) {
      throw ApiException("Something went wrong. Please try again.");
    }

    // Auto-refresh once on 401, then retry the original request.
    if (response.statusCode == 401 && auth && !isRetry) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(method, path, body: body, auth: auth, isRetry: true);
      }
    }

    return _decode(response);
  }

  Future<http.Response> _request(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    final encodedBody = body != null ? jsonEncode(body) : null;
    switch (method) {
      case "POST":
        return http.post(uri, headers: headers, body: encodedBody);
      case "PATCH":
        return http.patch(uri, headers: headers, body: encodedBody);
      case "DELETE":
        return http.delete(uri, headers: headers, body: encodedBody);
      default:
        return http.get(uri, headers: headers);
    }
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await SecureStorage.read(StorageKeys.refreshToken);
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$_base/api/auth/refresh"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken",
        },
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await SecureStorage.write(StorageKeys.accessToken, data["access_token"] as String);
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        // Non-JSON body (unexpected) — fall through with empty map.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw ApiException(
      (data["error"] as String?) ?? "Request failed (${response.statusCode})",
      statusCode: response.statusCode,
      fieldErrors: (data["field_errors"] as Map?)?.cast<String, dynamic>(),
    );
  }
}
