import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import 'api_config.dart';

class PaymentService {
  Future<PaymentOrderModel> createOrder({required String eventId, required String studentId}) async {
    final url = ApiConfig.getUri('/payment/create-order');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({'eventId': eventId, 'studentId': studentId}),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic>) {
      return PaymentOrderModel.fromJson(data);
    }
    throw ApiException('Failed to create payment order');
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String eventId,
    required String studentId,
    Map<String, dynamic>? formResponses,
  }) async {
    final url = ApiConfig.getUri('/payment/verify');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
        'eventId': eventId,
        'studentId': studentId,
        'formResponses': formResponses ?? {},
      }),
    );
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  Future<Map<String, dynamic>> getEventPaymentStats(String eventId) async {
    final url = ApiConfig.getUri('/payment/event/$eventId/stats');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {};
  }

  // Direct participation verification endpoint (/api/participation/verify/:qrCode)
  Future<Map<String, dynamic>> verifyQrParticipation(String qrCode) async {
    final url = ApiConfig.getUri('/participation/verify/${qrCode.trim()}');
    final response = await http.patch(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }
}
