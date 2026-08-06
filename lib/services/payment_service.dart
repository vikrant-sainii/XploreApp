import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'secure_storage_service.dart';

class PaymentService {
  static String get baseUrl => '${EnvConfig.baseUrl}/payment';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // PUT /api/payment/:participationId/review
  Future<Map<String, dynamic>> reviewPayment(
    String participationId, {
    required String status, // "APPROVED" | "REJECTED" | "NEED_MORE_DETAILS"
    String? message,
  }) async {
    final url = Uri.parse('$baseUrl/$participationId/review');
    final headers = await _getHeaders();
    final body = {
      'status': status,
      if (message != null) 'message': message,
    };
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Payment reviewed successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to review payment',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
