import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/event_model.dart';
import '../models/participation_model.dart';
import 'secure_storage_service.dart';

class EventService {
  static String get baseUrl => '${EnvConfig.baseUrl}/events';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/events - Get all published events
  Future<List<EventModel>> getEvents({int page = 1, int limit = 50}) async {
    final url = Uri.parse('$baseUrl?page=$page&limit=$limit');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error loading events: $e');
    }
  }

  // GET /api/events/club/:clubId - Get public club events
  Future<List<EventModel>> getClubEvents(String clubId) async {
    final url = Uri.parse('$baseUrl/club/$clubId');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load club events');
      }
    } catch (e) {
      throw Exception('Error loading club events: $e');
    }
  }

  // GET /api/events/club-manage/:clubId - Get manage view club events (requires auth)
  Future<List<EventModel>> getClubManageEvents(String clubId) async {
    final url = Uri.parse('$baseUrl/club-manage/$clubId');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load managed club events');
      }
    } catch (e) {
      throw Exception('Error loading managed club events: $e');
    }
  }

  // GET /api/events/:id - Get detailed event info
  Future<EventModel> getEventDetails(String idOrSlug) async {
    final url = Uri.parse('$baseUrl/$idOrSlug');
    final headers = await _getHeaders(); // Optional auth for viewing status
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EventModel.fromJson(data);
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (e) {
      throw Exception('Error loading event details: $e');
    }
  }

  // POST /api/events/:id/register - Register for event
  Future<Map<String, dynamic>> registerForEvent(
    String eventId, {
    String? externalEmail,
    String? externalName,
    String? transactionId,
    String? payerName,
    String? paymentRemarks,
    Map<String, dynamic>? formResponses,
  }) async {
    final url = Uri.parse('$baseUrl/$eventId/register');
    final headers = await _getHeaders();
    final body = {
      if (externalEmail != null) 'externalEmail': externalEmail,
      if (externalName != null) 'externalName': externalName,
      if (transactionId != null) 'transactionId': transactionId,
      if (payerName != null) 'payerName': payerName,
      if (paymentRemarks != null) 'paymentRemarks': paymentRemarks,
      if (formResponses != null) 'formResponses': formResponses,
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registered successfully',
          'status': data['status'],
          'qrCode': data['qrCode'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET /api/events/user/:userId - Get events a user is registered for
  Future<List<ParticipationModel>> getUserRegisteredEvents(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ParticipationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load registered events');
      }
    } catch (e) {
      throw Exception('Error loading registered events: $e');
    }
  }

  // DELETE /api/events/:id/register - Deregister from event
  Future<Map<String, dynamic>> deregisterFromEvent(String eventId, String studentId) async {
    final url = Uri.parse('$baseUrl/$eventId/register');
    final headers = await _getHeaders();
    final body = {'studentId': studentId};
    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Deregistered successfully'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Deregistration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/events - Create a new event
  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(eventData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return EventModel.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        String msg = data['message'] ?? data['error'] ?? '';
        if (data['errors'] != null) {
          if (data['errors'] is List) {
            msg += (msg.isNotEmpty ? ': ' : '') + (data['errors'] as List).join(', ');
          } else if (data['errors'] is Map) {
            msg += (msg.isNotEmpty ? ': ' : '') + (data['errors'] as Map).values.join(', ');
          }
        }
        if (msg.isEmpty) {
          msg = 'Validation or request failed (${response.statusCode})';
        }
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }


  // PUT /api/events/:id - Update an event
  Future<EventModel> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final url = Uri.parse('$baseUrl/$eventId');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(eventData),
      );
      if (response.statusCode == 200) {
        return EventModel.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update event');
      }
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  // DELETE /api/events/:id - Delete an event
  Future<void> deleteEvent(String eventId) async {
    final url = Uri.parse('$baseUrl/$eventId');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete event');
      }
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }
}
