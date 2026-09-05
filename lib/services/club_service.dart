import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/club_model.dart';
import '../models/event_model.dart';
import 'api_config.dart';

class ClubService {
  Future<List<ClubModel>> getAllClubs() async {
    final url = ApiConfig.getUri('/clubs');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: false));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((c) => ClubModel.fromJson(c)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getClubDetails(String clubId) async {
    final url = ApiConfig.getUri('/clubs/$clubId');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: false));
    final data = ApiConfig.handleResponse(response);

    ClubModel? club;
    List<EventModel> events = [];

    if (data is Map<String, dynamic>) {
      if (data['club'] is Map<String, dynamic>) {
        club = ClubModel.fromJson(data['club']);
      }
      if (data['events'] is List) {
        events = (data['events'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => EventModel.fromJson(e))
            .toList();
      }
    }
    return {'club': club, 'events': events};
  }

  Future<ClubModel> updateClub(String id, Map<String, dynamic> clubData) async {
    final url = ApiConfig.getUri('/clubs/$id');
    final response = await http.put(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode(clubData),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic> && data['club'] is Map<String, dynamic>) {
      return ClubModel.fromJson(data['club']);
    }
    throw ApiException('Failed to parse updated club');
  }

  // Club Members
  Future<List<ClubMembershipModel>> getClubMembers(String clubId) async {
    final url = ApiConfig.getUri('/club-members/$clubId/members');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    final data = ApiConfig.handleResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((m) => ClubMembershipModel.fromJson(m)).toList();
    }
    return [];
  }

  Future<ClubMembershipModel> addClubMember(String clubId, String email, {String role = 'MEMBER'}) async {
    final url = ApiConfig.getUri('/club-members/$clubId/members');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode({'email': email.trim(), 'role': role}),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic> && data['membership'] is Map<String, dynamic>) {
      return ClubMembershipModel.fromJson(data['membership']);
    }
    throw ApiException('Failed to parse new club member');
  }

  Future<ClubMembershipModel> updateMemberPermissions(
    String membershipId, {
    String? role,
    bool? canTakeAttendance,
    bool? canEditEvents,
  }) async {
    final url = ApiConfig.getUri('/club-members/members/$membershipId');
    final body = <String, dynamic>{};
    if (role != null) body['role'] = role;
    if (canTakeAttendance != null || canEditEvents != null) {
      body['permissions'] = {
        if (canTakeAttendance != null) 'canTakeAttendance': canTakeAttendance,
        if (canEditEvents != null) 'canEditEvents': canEditEvents,
      };
    }

    final response = await http.put(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode(body),
    );
    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic> && data['membership'] is Map<String, dynamic>) {
      return ClubMembershipModel.fromJson(data['membership']);
    }
    throw ApiException('Failed to parse updated member');
  }

  Future<void> removeClubMember(String membershipId) async {
    final url = ApiConfig.getUri('/club-members/members/$membershipId');
    final response = await http.delete(url, headers: await ApiConfig.getHeaders(requireAuth: true));
    ApiConfig.handleResponse(response);
  }
}
