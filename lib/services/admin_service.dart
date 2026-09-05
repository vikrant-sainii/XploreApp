import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AdminService {
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = ApiConfig.getUri('/admin/dashboard-stats');
    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
      );
      final data = ApiConfig.handleResponse(response);
      return Map<String, dynamic>.from(data is Map ? data : {});
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getClubsList() async {
    final url = ApiConfig.getUri('/admin/clubs-list');
    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
      );
      final data = ApiConfig.handleResponse(response);
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createClub({
    required String clubName,
    required String facultyName,
    required String facultyEmail,
    required String clubEmail,
  }) async {
    final url = ApiConfig.getUri('/admin/clubs');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
        body: jsonEncode({
          'clubName': clubName.trim(),
          'facultyName': facultyName.trim(),
          'facultyEmail': facultyEmail.trim(),
          'clubEmail': clubEmail.trim(),
        }),
      );
      final data = ApiConfig.handleResponse(response);
      return Map<String, dynamic>.from(data is Map ? data : {});
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateClub(String id, Map<String, dynamic> updateData) async {
    final url = ApiConfig.getUri('/admin/clubs/$id');
    try {
      final response = await http.put(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
        body: jsonEncode(updateData),
      );
      final data = ApiConfig.handleResponse(response);
      return Map<String, dynamic>.from(data is Map ? data : {});
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getCoordinators() async {
    final url = ApiConfig.getUri('/admin/coordinators');
    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
      );
      final data = ApiConfig.handleResponse(response);
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createCoordinator({
    required String name,
    required String email,
    String? password,
  }) async {
    final url = ApiConfig.getUri('/admin/coordinators');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          if (password != null && password.isNotEmpty) 'password': password,
        }),
      );
      final data = ApiConfig.handleResponse(response);
      return Map<String, dynamic>.from(data is Map ? data : {});
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateCoordinator(String id, Map<String, dynamic> data) async {
    final url = ApiConfig.getUri('/admin/coordinators/$id');
    try {
      final response = await http.put(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
        body: jsonEncode(data),
      );
      final resData = ApiConfig.handleResponse(response);
      return Map<String, dynamic>.from(resData is Map ? resData : {});
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> completePayout(String eventId) async {
    final url = ApiConfig.getUri('/admin/complete-payout/$eventId');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
      );
      final data = ApiConfig.handleResponse(response);
      return Map<String, dynamic>.from(data is Map ? data : {});
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getEventDataExport({
    String? month,
    String? year,
    String? clubId,
  }) async {
    final query = <String, dynamic>{
      if (month != null && month.isNotEmpty) 'month': month,
      if (year != null && year.isNotEmpty) 'year': year,
      if (clubId != null && clubId.isNotEmpty) 'clubId': clubId,
    };
    final url = ApiConfig.getUri('/admin/event-data-export', query);
    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
      );
      final data = ApiConfig.handleResponse(response);
      if (data is Map && data['events'] is List) {
        return (data['events'] as List).whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
