import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/notification_model.dart';
import 'secure_storage_service.dart';

class NotificationService {
  static String get baseUrl => '${EnvConfig.baseUrl}/notifications';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/notifications - Get user notifications
  Future<List<NotificationModel>> getNotifications() async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  // GET /api/notifications/sent - Get sent notifications (club head)
  Future<List<NotificationModel>> getSentNotifications() async {
    final url = Uri.parse('$baseUrl/sent');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sent notifications');
      }
    } catch (e) {
      throw Exception('Error loading sent notifications: $e');
    }
  }

  // POST /api/notifications - Create and broadcast notification
  Future<NotificationModel> sendNotification({
    required String targetType, // "REGISTERED_STUDENTS" | "ALL_STUDENTS"
    String? eventId,
    required String title,
    required String message,
  }) async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    final body = {
      'targetType': targetType,
      if (eventId != null) 'eventId': eventId,
      'title': title,
      'message': message,
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return NotificationModel.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to send notification');
      }
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }

  // PUT /api/notifications/read-all - Mark all read
  Future<void> markAllRead() async {
    final url = Uri.parse('$baseUrl/read-all');
    final headers = await _getHeaders();
    try {
      final response = await http.put(url, headers: headers);
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to mark all as read');
      }
    } catch (e) {
      throw Exception('Error marking all read: $e');
    }
  }

  // PUT /api/notifications/:id/read - Mark single read
  Future<NotificationModel> markRead(String id) async {
    final url = Uri.parse('$baseUrl/$id/read');
    final headers = await _getHeaders();
    try {
      final response = await http.put(url, headers: headers);
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Error marking notification read: $e');
    }
  }
}
