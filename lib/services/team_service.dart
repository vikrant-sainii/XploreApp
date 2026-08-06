import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/team_model.dart';
import 'secure_storage_service.dart';

class TeamService {
  static String get baseUrl => '${EnvConfig.baseUrl}/teams';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // POST /api/teams - Register a team
  Future<Map<String, dynamic>> registerTeam(Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Team registered successfully',
          'teamId': responseData['teamId'],
          'status': responseData['status'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to register team',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/teams/invitations/:id/accept - Accept invitation
  Future<Map<String, dynamic>> acceptInvitation(String notificationId) async {
    final url = Uri.parse('$baseUrl/invitations/$notificationId/accept');
    final headers = await _getHeaders();
    try {
      final response = await http.post(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'status': data['status'],
          'message': data['message'] ?? 'Invitation accepted',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to accept invitation',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/teams/invitations/:id/decline - Decline invitation
  Future<Map<String, dynamic>> declineInvitation(String notificationId) async {
    final url = Uri.parse('$baseUrl/invitations/$notificationId/decline');
    final headers = await _getHeaders();
    try {
      final response = await http.post(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Invitation declined',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to decline invitation',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/teams/:id/invite - Invite member
  Future<Map<String, dynamic>> inviteMember(String teamId, String studentId) async {
    final url = Uri.parse('$baseUrl/$teamId/invite');
    final headers = await _getHeaders();
    final body = {'studentId': studentId};
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Teammate invited successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to invite teammate',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET /api/teams/:id - Get team details
  Future<TeamModel> getTeamDetails(String teamId) async {
    final url = Uri.parse('$baseUrl/$teamId');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return TeamModel.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to get team details');
      }
    } catch (e) {
      throw Exception('Error loading team details: $e');
    }
  }
}
