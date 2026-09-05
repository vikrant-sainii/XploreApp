import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class ApiConfig {
  // Deployed active working production server URL
  static const String cloudBaseUrl = 'https://campusnode-server.onrender.com/api';
  static String baseUrl = cloudBaseUrl;

  static final SecureStorageService _storage = SecureStorageService();

  static void useCloudServer() {
    baseUrl = cloudBaseUrl;
  }

  static void setCustomBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.isEmpty) {
      baseUrl = cloudBaseUrl;
      return;
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    baseUrl = trimmed.endsWith('/api') ? trimmed : '$trimmed/api';
  }

  static Future<Map<String, String>> getHeaders({bool requireAuth = true}) async {
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
      final stringParams = queryParameters.map((k, v) => MapEntry(k, v.toString()));
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
      String cleanMsg = 'CampusNode server is currently unavailable or undergoing maintenance.';
      if (rawText.contains('Service Suspended')) {
        cleanMsg = 'CampusNode service is currently suspended by host.';
      }
      throw ApiException(cleanMsg, statusCode: response.statusCode, responseBody: rawText);
    }

    try {
      body = jsonDecode(rawText);
    } catch (_) {
      body = rawText;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage = 'Request failed with status code ${response.statusCode}';
      if (body is Map) {
        errorMessage = body['message']?.toString() ?? body['error']?.toString() ?? errorMessage;
      } else if (body is String && body.isNotEmpty && !isHtml) {
        errorMessage = body;
      }
      throw ApiException(errorMessage, statusCode: response.statusCode, responseBody: body);
    }
  }

  static void showServerConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: const [
            Icon(Icons.dns, color: Color(0xFF191C32)),
            SizedBox(width: 10),
            Text("Server Configuration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Deployed Server:",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ListTile(
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              tileColor: const Color(0xFFDEF5E9),
              leading: const Icon(Icons.cloud_done, color: Color(0xFF5FC88F)),
              title: const Text("CampusNode Production Server", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text("https://campusnode-server.onrender.com/api", style: TextStyle(fontSize: 11, color: Colors.black54)),
              onTap: () {
                useCloudServer();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Server set to: $baseUrl"), backgroundColor: Colors.green),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Custom Server Endpoint",
                hintText: "https://campusnode-server.onrender.com/api",
                filled: true,
                fillColor: const Color(0xFFF7F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setCustomBaseUrl(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Server set to: $baseUrl"), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF191C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Save Endpoint", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
