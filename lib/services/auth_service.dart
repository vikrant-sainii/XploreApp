import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'secure_storage_service.dart';

class AuthService {
  // Production URL
  static const String baseUrl = 'https://clubsetu-backend.onrender.com/api/auth';
  
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<Map<String, dynamic>> login(String email, String password, {bool isAdmin = false}) async {
    final endpoint = isAdmin ? '/login/admin' : '/login/student';
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assume backend returns token in 'token' or 'access_token' field
        final token = data['token'] ?? data['access_token'];
        if (token != null) {
          await _secureStorageService.saveToken(token);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerStudent(UserModel user, String password) async {
    final url = Uri.parse('$baseUrl/register/student');

    try {
      final body = user.toJson();
      body['password'] = password; // Add password to the request

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _secureStorageService.deleteAll();
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message'] ?? 'Check your email for OTP'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password/$token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': newPassword}),
      );

      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message'] ?? 'Password reset successfully'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final url = Uri.parse('$baseUrl/verify-email/$token');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message'] ?? 'Email verified successfully'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/change-password');
    final token = await _secureStorageService.getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message'] ?? 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
