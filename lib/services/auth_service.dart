import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/user_model.dart';
import 'secure_storage_service.dart';

/// All auth routes are mapped 1-to-1 with the Express backend in auth.js.
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

  /// Parses `{ success, user, role, userType, token, needs2FA }` payloads.
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

      final userJson = data['user'] as Map<String, dynamic>?;
      final role = data['role'] as String? ?? 'member';
      final userType = data['userType'] as String? ?? 'student';

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

      // In dev mode the backend auto-logs in; persist session if token present
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
  // POST /api/auth/login/admin
  Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login/admin');
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
        await _persistSession(data, user?.role ?? 'admin');
      }
      return result;
    } catch (e) {
      String msg = 'Admin login failed. Please check your internet connection.';
      if (e.toString().contains('TimeoutException')) {
        msg = 'Backend server takes too long to respond. Please try again.';
      }
      return {'success': false, 'message': msg};
    }
  }

  // ─── EXTERNAL REGISTRATION ─────────────────────────────────────────────────
  // POST /api/auth/register/external
  // Sends an OTP to the provided email; no password needed.
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
  // Used for both student and admin 2FA flows.
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
  // GET /api/auth/verify-email/:token
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
  // POST /api/auth/forgot-password
  // Works for both students and admins; backend identifies by email.
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
  // POST /api/auth/reset-password/:token
  // `token` is the raw token from the reset email URL (backend will hash it).
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/reset-password/$token');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'newPassword': newPassword}), // ← key matches backend
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
  // POST /api/auth/change-password   (requires JWT)
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
          'currentPassword': currentPassword, // ← key matches backend
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
  // POST /api/auth/logout  — clears the httpOnly cookie on the server side,
  // and deletes local secure storage.
  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      await http.post(url, headers: _jsonHeaders);
    } catch (_) {
      // Best-effort: still clear local storage even if server call fails
    }
    await _storage.deleteAll();
    return {'success': true};
  }

  // ─── SESSION HELPERS ───────────────────────────────────────────────────────

  /// Returns the stored JWT, or null if the user is not logged in.
  Future<String?> getToken() => _storage.getToken();

  /// Returns the stored role string, or null.
  Future<String?> getRole() => _storage.getRole();
}
