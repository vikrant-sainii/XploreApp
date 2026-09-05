import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<Map<String, dynamic>> loginStudent(String email, String password) async {
    final url = ApiConfig.getUri('/auth/login/student');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final data = ApiConfig.handleResponse(response);
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await _secureStorageService.saveToken(token.toString());
      }
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    // 1. Try primary admin route (/api/admin/login)
    try {
      final urlAdmin = ApiConfig.getUri('/admin/login');
      final response = await http.post(
        urlAdmin,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final data = ApiConfig.handleResponse(response);
      if (data['needs2FA'] == true) {
        return {'success': true, 'needs2FA': true, 'email': data['email'] ?? email, 'message': data['message']};
      }

      final token = data['token'] ?? data['access_token'] ?? data['admin']?['token'];
      if (token != null) {
        await _secureStorageService.saveToken(token.toString());
      } else {
        await _secureStorageService.saveToken('admin_token_${DateTime.now().millisecondsSinceEpoch}');
      }
      return {'success': true, 'data': data};
    } catch (_) {}

    // 2. Try /api/auth/login/admin route
    try {
      final urlAuthAdmin = ApiConfig.getUri('/auth/login/admin');
      final response = await http.post(
        urlAuthAdmin,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final data = ApiConfig.handleResponse(response);
      if (data['needs2FA'] == true) {
        return {'success': true, 'needs2FA': true, 'email': data['email'] ?? email, 'message': data['message']};
      }

      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await _secureStorageService.saveToken(token.toString());
      }
      return {'success': true, 'data': data};
    } catch (_) {}

    // 3. Fallback to student login for Club Heads / Coordinators
    final studentRes = await loginStudent(email, password);
    if (studentRes['success'] == true) {
      return studentRes;
    }
    return {'success': false, 'message': 'Invalid Admin Credentials'};
  }

  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
    required String password,
    required String program,
    String? rollNo,
    String? branch,
    dynamic year,
  }) async {
    final url = ApiConfig.getUri('/auth/register/student');
    try {
      int? yearNum;
      if (year != null) {
        yearNum = int.tryParse(year.toString());
      }

      final body = {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'program': program.toUpperCase(),
        if (rollNo != null && rollNo.isNotEmpty) 'rollNo': rollNo.trim(),
        if (branch != null && branch.isNotEmpty) 'branch': branch.trim(),
        if (yearNum != null) 'year': yearNum,
      };

      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode(body),
      );

      final data = ApiConfig.handleResponse(response);
      if (data['token'] != null) {
        await _secureStorageService.saveToken(data['token'].toString());
      }
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerExternal(String name, String email) async {
    final url = ApiConfig.getUri('/auth/register/external');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'name': name.trim(), 'email': email.trim()}),
      );
      final data = ApiConfig.handleResponse(response);
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginExternal(String email, String otp) async {
    final url = ApiConfig.getUri('/auth/login/external');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'email': email.trim(), 'otp': otp.trim()}),
      );
      final data = ApiConfig.handleResponse(response);
      final token = data['token'];
      if (token != null) {
        await _secureStorageService.saveToken(token.toString());
      }
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verify2FA(String email, String otp) async {
    final url = ApiConfig.getUri('/auth/verify-2fa');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'email': email.trim(), 'otp': otp.trim()}),
      );
      final data = ApiConfig.handleResponse(response);
      final token = data['token'];
      if (token != null) {
        await _secureStorageService.saveToken(token.toString());
      }
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final url = ApiConfig.getUri('/auth/verify-email/$token');
    try {
      final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: false));
      final data = ApiConfig.handleResponse(response);
      return {'success': true, 'message': data['message'] ?? 'Email verified'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = ApiConfig.getUri('/auth/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'email': email.trim()}),
      );
      final data = ApiConfig.handleResponse(response);
      return {'success': true, 'message': data['message'] ?? 'Reset instructions sent'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final url = ApiConfig.getUri('/auth/reset-password/$token');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode({'newPassword': newPassword}),
      );
      final data = ApiConfig.handleResponse(response);
      return {'success': true, 'message': data['message'] ?? 'Password reset successfully'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final url = ApiConfig.getUri('/auth/change-password');
    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      final data = ApiConfig.handleResponse(response);
      return {'success': true, 'message': data['message'] ?? 'Password changed successfully'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _secureStorageService.deleteAll();
  }

  // Backwards compatible login method
  Future<Map<String, dynamic>> login(String email, String password, {bool isAdmin = false}) async {
    if (isAdmin) {
      return loginAdmin(email, password);
    } else {
      return loginStudent(email, password);
    }
  }
}
