import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../models/participation_model.dart';
import 'api_config.dart';

class EventService {
  Future<List<EventModel>> getAllEvents() async {
    final url = ApiConfig.getUri('/events');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: false));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((e) => EventModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<String>> getVenues() async {
    try {
      final url = ApiConfig.getUri('/venues');
      final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: false));
      final data = ApiConfig.handleResponse(response);
      if (data is List) {
        final list = data
            .map((e) => e is Map ? (e['name'] ?? e['venueName'] ?? e['title'] ?? e.toString()).toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return ['CSH', 'Main Auditorium', 'A3, Civil Building', 'WE1', 'WE2', 'MBA Dept', 'IT Seminar Hall', 'Open Air Theatre (OAT)', 'Online'];
  }


  Future<EventModel> getEventById(String id) async {
    final url = ApiConfig.getUri('/events/$id');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is Map<String, dynamic>) {
      return EventModel.fromJson(data);
    }
    throw ApiException('Failed to parse event details');
  }

  Future<List<EventModel>> getEventsByClub(String clubId) async {
    final url = ApiConfig.getUri('/events/club/$clubId');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: false));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((e) => EventModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<EventModel>> getClubManageEvents(String clubId) async {
    final url = ApiConfig.getUri('/events/club-manage/$clubId');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((e) => EventModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<EventModel>> getCoordinatorEvents(String userId) async {
    final url = ApiConfig.getUri('/events/club-co/$userId');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((e) => EventModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ParticipationModel>> getUserParticipations(String userId) async {
    final url = ApiConfig.getUri('/events/user/$userId');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      if (data['participations'] is List) {
        rawList = data['participations'] as List;
      } else if (data['data'] is List) {
        rawList = data['data'] as List;
      } else if (data['events'] is List) {
        rawList = data['events'] as List;
      } else if (data['registrations'] is List) {
        rawList = data['registrations'] as List;
      }
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((p) => ParticipationModel.fromJson(p))
        .toList();
  }

  Future<String?> uploadPoster(dynamic file) async {
    try {
      final url = ApiConfig.getUri('/events/upload');
      final request = http.MultipartRequest('POST', url);
      final headers = await ApiConfig.getHeaders(requireAuth: true);
      request.headers.addAll(headers);

      List<int> bytes;
      String filename = 'poster.jpg';
      if (file is String) {
        bytes = await File(file).readAsBytes();
        filename = file.split('/').last;
      } else {
        bytes = await file.readAsBytes();
        if (file.name != null && file.name.toString().isNotEmpty) {
          filename = file.name.toString();
        }
      }

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = ApiConfig.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data['imageUrl']?.toString() ??
            data['secure_url']?.toString() ??
            data['url']?.toString() ??
            data['imageLocation']?.toString();
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    final url = ApiConfig.getUri('/events');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode(eventData),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic>) {
      return EventModel.fromJson(data);
    }
    throw ApiException('Failed to parse created event');
  }

  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData) async {
    final url = ApiConfig.getUri('/events/$id');
    final response = await http.put(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode(eventData),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic>) {
      return EventModel.fromJson(data);
    }
    throw ApiException('Failed to parse updated event');
  }

  Future<void> deleteEvent(String id) async {
    final url = ApiConfig.getUri('/events/$id');
    final response = await http.delete(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    ApiConfig.handleResponse(response);
  }

  Future<Map<String, dynamic>> reviewEvent(String id, {required String status, String? comment}) async {
    final url = ApiConfig.getUri('/events/$id/review');
    final response = await http.put(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({'status': status, if (comment != null) 'comment': comment}),
    );
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  Future<Map<String, dynamic>> registerForEvent(
    String eventId, {
    String? externalEmail,
    String? externalName,
    Map<String, dynamic>? formResponses,
  }) async {
    final url = ApiConfig.getUri('/events/$eventId/register');
    final body = <String, dynamic>{};
    if (externalEmail != null && externalEmail.isNotEmpty) {
      body['externalEmail'] = externalEmail;
      body['externalName'] = externalName ?? '';
    }
    if (formResponses != null && formResponses.isNotEmpty) {
      body['formResponses'] = formResponses;
    }

    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode(body),
    );
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  Future<void> deregisterFromEvent(String eventId, String studentId) async {
    final url = ApiConfig.getUri('/events/$eventId/register');
    final response = await http.delete(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({'studentId': studentId}),
    );
    ApiConfig.handleResponse(response);
  }

  Future<List<ParticipationModel>> getEventRegistrations(String eventId) async {
    final url = ApiConfig.getUri('/events/$eventId/registrations');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is Map<String, dynamic> && data['participations'] is List) {
      return (data['participations'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => ParticipationModel.fromJson(p))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> checkInQr(String eventId, String qrCode) async {
    final url = ApiConfig.getUri('/events/$eventId/check-in');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({'qrCode': qrCode.trim()}),
    );
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  Future<Map<String, dynamic>> checkInManual(String eventId, String participationId, {String type = 'internal'}) async {
    final url = ApiConfig.getUri('/events/$eventId/attendance-manual');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({'participationId': participationId, 'type': type}),
    );
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }
}
