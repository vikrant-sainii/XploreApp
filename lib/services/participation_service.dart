import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/participation_model.dart';
import 'secure_storage_service.dart';

class ParticipationService {
  static String get baseUrl => '${EnvConfig.baseUrl}/participation';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // PATCH /api/participation/verify/:qrCode - QR attendance scan
  Future<Map<String, dynamic>> verifyQR(String qrCode) async {
    final url = Uri.parse('$baseUrl/verify/$qrCode');
    final headers = await _getHeaders();
    try {
      final response = await http.patch(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'participantName': data['participantName'] as String?,
          'rollNo': data['rollNo'] as String?,
          'externalEmail': data['externalEmail'] as String?,
          'attendedAt': data['attendedAt'] != null ? DateTime.tryParse(data['attendedAt']) : null,
          'markedByMemberId': data['markedByMemberId'] as String?,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark attendance',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET /api/events/:id/registrations - Get event registrations list
  Future<List<ParticipationModel>> getEventRegistrations(String eventId) async {
    final url = Uri.parse('${EnvConfig.baseUrl}/events/$eventId/registrations');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ParticipationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load event registrations');
      }
    } catch (e) {
      throw Exception('Error loading event registrations: $e');
    }
  }
}
