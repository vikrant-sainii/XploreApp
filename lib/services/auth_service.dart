import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/user_model.dart';
import 'secure_storage_service.dart';

/// All auth routes are mapped 1-to-1 with the Express backend in auth.js and admin.js.
class AuthService {
  // ─── Base URL ──────────────────────────────────────────────────────────────
  static String get baseUrl => '${EnvConfig.baseUrl}/auth';

  final SecureStorageService _storage = SecureStorageService();

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Persists token + role from a successful login/register response.
  Future<void> _persistSession(Map<String, dynamic> data, String role) async {
    final token = data['token'] as String?;
    if (token != null) {
      await _storage.saveToken(token);
    }
    await _storage.saveRole(role);
  }

  /// Parses `{ success, user, admin, role, userType, token, needs2FA }` payloads.
  Map<String, dynamic> _parseAuthResponse(
      http.Response response, Map<String, dynamic> data) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 2FA pending — backend hasn't issued a token yet
      if (data['needs2FA'] == true) {
        return {
          'success': true,
          'needs2FA': true,
          'email': data['email'],
          'message': data['message'],
        };
      }

      // Support both `data['user']` (from /auth/login/admin) and `data['admin']` (from /admin/login)
      final userJson = (data['user'] ?? data['admin']) as Map<String, dynamic>?;
      final role = data['role'] as String? ?? userJson?['role'] as String? ?? 'admin';
      final userType = data['userType'] as String? ?? 'admin';

      return {
        'success': true,
        'user': userJson != null
            ? UserModel.fromJson({...userJson, 'role': role, 'userType': userType})
            : null,
        'role': role,
        'userType': userType,
        'token': data['token'],
        'message': data['message'],
        'needs2FA': false,
      };
    }
    return {
      'success': false,
      'message': data['message'] ?? 'Request failed (${response.statusCode})',
    };
  }

  // ─── STUDENT REGISTRATION ──────────────────────────────────────────────────
  // POST /api/auth/register/student
  Future<Map<String, dynamic>> registerStudent(
    UserModel user,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register/student');
    try {
      final body = {
        'name': user.name,
        'rollNo': user.rollNo,
        'branch': user.branch,
        'year': user.year,
        'program': user.program ?? 'BTECH',
        'email': user.email,
        'password': password,
      };
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = _parseAuthResponse(response, data);

      if (result['success'] == true && result['needs2FA'] == false) {
        final user = result['user'] as UserModel?;
        if (user != null) {
          await _persistSession(data, user.role);
        }
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── STUDENT LOGIN ─────────────────────────────────────────────────────────
  // POST /api/auth/login/student
  Future<Map<String, dynamic>> loginStudent(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login/student');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 45));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = _parseAuthResponse(response, data);
      if (result['success'] == true && result['needs2FA'] == false) {
        final user = result['user'] as UserModel?;
        await _persistSession(data, user?.role ?? 'member');
      }
      return result;
    } catch (e) {
      String msg = 'Login failed. Please check your internet connection.';
      if (e.toString().contains('TimeoutException')) {
        msg = 'Backend server takes too long to respond (warmup required). Please try again in a few seconds.';
      } else if (e is FormatException) {
        msg = 'Invalid server response.';
      }
      return {'success': false, 'message': msg};
    }
  }

  // ─── ADMIN LOGIN ───────────────────────────────────────────────────────────
  // Tries POST /api/admin/login (web client route) first, falls back to POST /api/auth/login/admin
  Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    try {
      // 1. Primary route matching web client AdminLogin.jsx
      var url = Uri.parse('${EnvConfig.baseUrl}/admin/login');
      var response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      var data = jsonDecode(response.body) as Map<String, dynamic>;

      // 2. Fallback to /api/auth/login/admin if /admin/login returned non-200
      if (response.statusCode != 200 && response.statusCode != 201) {
        final authAdminUrl = Uri.parse('$baseUrl/login/admin');
        final authResponse = await http.post(
          authAdminUrl,
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 30));
        if (authResponse.statusCode == 200 || authResponse.statusCode == 201) {
          response = authResponse;
          data = jsonDecode(authResponse.body) as Map<String, dynamic>;
        }
      }

      final result = _parseAuthResponse(response, data);
      if (result['success'] == true && result['needs2FA'] == false) {
        final user = result['user'] as UserModel?;
        final role = result['role'] as String? ?? user?.role ?? 'admin';
        await _persistSession(data, role);
      }
      return result;
    } catch (e) {
      String msg = 'Admin login failed. Please check your internet connection.';
      if (e.toString().contains('TimeoutException')) {
        msg = 'Backend server takes too long to respond. Please try again.';
      }
      return {'success': false, 'message': e.toString().contains('Timeout') ? msg : e.toString()};
    }
  }

  // ─── EXTERNAL REGISTRATION ─────────────────────────────────────────────────
  // POST /api/auth/register/external
  Future<Map<String, dynamic>> registerExternal(
    String name,
    String email,
  ) async {
    final url = Uri.parse('$baseUrl/register/external');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'name': name, 'email': email}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'], 'email': data['email']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── EXTERNAL LOGIN (OTP) ──────────────────────────────────────────────────
  // POST /api/auth/login/external
  Future<Map<String, dynamic>> loginExternal(
    String email,
    String otp,
  ) async {
    final url = Uri.parse('$baseUrl/login/external');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = _parseAuthResponse(response, data);
      if (result['success'] == true) {
        await _persistSession(data, 'external');
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── 2FA VERIFICATION ──────────────────────────────────────────────────────
  // POST /api/auth/verify-2fa
  Future<Map<String, dynamic>> verify2FA(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-2fa');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = _parseAuthResponse(response, data);
      if (result['success'] == true) {
        final user = result['user'] as UserModel?;
        await _persistSession(data, user?.role ?? 'member');
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── EMAIL VERIFICATION ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final url = Uri.parse('$baseUrl/verify-email/$token');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Email verified successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── FORGOT PASSWORD ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Check your email for the reset link',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── RESET PASSWORD ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/reset-password/$token');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'newPassword': newPassword}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── CHANGE PASSWORD ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/change-password');
    final headers = await _authHeaders;
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Password changed successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── LOGOUT ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      await http.post(url, headers: _jsonHeaders);
    } catch (_) {}
    await _storage.deleteAll();
    return {'success': true};
  }

  // ─── SESSION HELPERS ───────────────────────────────────────────────────────
  Future<String?> getToken() => _storage.getToken();
  Future<String?> getRole() => _storage.getRole();
}
