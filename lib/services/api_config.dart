import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class ApiConfig {
  // Deployed active working production server URL
  static const String cloudBaseUrl = 'https://campusnode-cn.onrender.com/api';
  static String baseUrl = cloudBaseUrl;

  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> getHeaders(
      {bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Uri getUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$baseUrl$cleanPath';
    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams =
          queryParameters.map((k, v) => MapEntry(k, v.toString()));
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  static dynamic handleResponse(http.Response response) {
    dynamic body;
    final rawText = response.body.trim();

    // Check if server returned non-JSON HTML (e.g. 503 Service Suspended, 404, or 500 HTML)
    final bool isHtml = rawText.startsWith('<!DOCTYPE') ||
        rawText.startsWith('<html') ||
        rawText.contains('Service Suspended') ||
        rawText.contains('</body>');

    if (isHtml) {
      String cleanMsg =
          'CampusNode server is currently unavailable or undergoing maintenance.';
      if (rawText.contains('Service Suspended')) {
        cleanMsg = 'CampusNode service is currently suspended by host.';
      }
      throw ApiException(cleanMsg,
          statusCode: response.statusCode, responseBody: rawText);
    }

    try {
      body = jsonDecode(rawText);
    } catch (_) {
      body = rawText;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage =
          'Request failed with status code ${response.statusCode}';
      if (body is Map) {
        errorMessage = body['message']?.toString() ??
            body['error']?.toString() ??
            errorMessage;
      } else if (body is String && body.isNotEmpty && !isHtml) {
        errorMessage = body;
      }
      throw ApiException(errorMessage,
          statusCode: response.statusCode, responseBody: body);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic responseBody;

  ApiException(this.message, {this.statusCode = 500, this.responseBody});

  @override
  String toString() => message;
}
