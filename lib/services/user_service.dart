import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/user_model.dart';
import 'secure_storage_service.dart';

class UserService {
  static String get baseUrl => '${EnvConfig.baseUrl}/users';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/users/me
  Future<Map<String, dynamic>> getMe() async {
    final url = Uri.parse('$baseUrl/me');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'] as Map<String, dynamic>;
        final role = data['role'] as String? ?? 'member';
        final userType = data['userType'] as String? ?? 'student';

        final user = UserModel.fromJson({
          ...userJson,
          'role': role,
          'userType': userType,
        });

        return {
          'success': true,
          'user': user,
          'role': role,
          'userType': userType,
        };
      } else {
        return {'success': false, 'message': 'Failed to fetch profile'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT /api/users/:role/:id
  Future<Map<String, dynamic>> updateProfile(String role, String id, Map<String, dynamic> updateData) async {
    final url = Uri.parse('$baseUrl/$role/$id');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(updateData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final userJson = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET /api/users/search?query=...
  Future<List<UserModel>> searchStudents(String query) async {
    final url = Uri.parse('$baseUrl/search?query=$query');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search students');
      }
    } catch (e) {
      throw Exception('Error searching students: $e');
    }
  }

  // GET /api/users/lookup/:rollNo
  Future<Map<String, String>> lookupStudent(String rollNo) async {
    final url = Uri.parse('$baseUrl/lookup/$rollNo');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'name': data['name'] as String? ?? '',
          'branch': data['branch'] as String? ?? '',
        };
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      throw Exception('Error looking up student: $e');
    }
  }
}
