import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'api_config.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotifications() async {
    final url = ApiConfig.getUri('/notifications');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((n) => NotificationModel.fromJson(n)).toList();
    }
    return [];
  }

  Future<List<NotificationModel>> getSentNotifications() async {
    final url = ApiConfig.getUri('/notifications/sent');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((n) => NotificationModel.fromJson(n)).toList();
    }
    return [];
  }

  Future<NotificationModel> sendNotification({
    required String title,
    required String message,
    String targetType = 'ALL_STUDENTS',
    String? eventId,
  }) async {
    final url = ApiConfig.getUri('/notifications');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({
        'title': title.trim(),
        'message': message.trim(),
        'targetType': targetType,
        if (eventId != null && eventId.isNotEmpty) 'eventId': eventId,
      }),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic>) {
      return NotificationModel.fromJson(data);
    }
    throw ApiException('Failed to parse sent notification');
  }

  Future<void> markAllRead() async {
    final url = ApiConfig.getUri('/notifications/read-all');
    final response = await http.put(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    ApiConfig.handleResponse(response);
  }

  Future<void> markAsRead(String notificationId) async {
    final url = ApiConfig.getUri('/notifications/$notificationId/read');
    final response = await http.put(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    ApiConfig.handleResponse(response);
  }
}
