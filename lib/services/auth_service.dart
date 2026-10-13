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
    String? lastErrorMessage;

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
    } on ApiException catch (e) {
      lastErrorMessage = e.message;
    } catch (e) {
      lastErrorMessage = e.toString();
    }

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
    } on ApiException catch (e) {
      lastErrorMessage = e.message;
    } catch (e) {
      lastErrorMessage = e.toString();
    }

    // 3. Fallback to student login for Club Heads / Coordinators
    final studentRes = await loginStudent(email, password);
    if (studentRes['success'] == true) {
      return studentRes;
    }
    return {'success': false, 'message': studentRes['message'] ?? lastErrorMessage ?? 'Invalid Admin Credentials'};
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

  Future<Map<String, dynamic>> registerExternal({
    required String name,
    required String email,
    String? password,
    String? collegeName,
    String? phone,
    String? program,
    dynamic year,
  }) async {
    final yearVal = year != null ? (int.tryParse(year.toString()) ?? year) : null;
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      if (password != null && password.isNotEmpty) 'password': password,
      if (collegeName != null && collegeName.isNotEmpty) 'collegeName': collegeName.trim(),
      if (collegeName != null && collegeName.isNotEmpty) 'college': collegeName.trim(),
      if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
      if (program != null && program.isNotEmpty) 'program': program.trim(),
      if (yearVal != null) 'graduationYear': yearVal,
      if (yearVal != null) 'year': yearVal,
      'role': 'EXTERNAL',
      'userType': 'external',
    };

    // 1. Try primary external endpoint
    try {
      final url = ApiConfig.getUri('/auth/register/external');
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
      if (e.statusCode != 404) {
        return {'success': false, 'message': e.message};
      }
    } catch (_) {}

    // 2. Fallback to /auth/register/student
    try {
      final url = ApiConfig.getUri('/auth/register/student');
      final fallbackBody = {
        'name': name.trim(),
        'email': email.trim(),
        if (password != null && password.isNotEmpty) 'password': password,
        'program': 'OTHER',
        'branch': program ?? 'General',
        if (yearVal != null) 'year': yearVal,
        if (collegeName != null) 'collegeName': collegeName.trim(),
      };
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: false),
        body: jsonEncode(fallbackBody),
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


  Future<Map<String, dynamic>> registerFaculty({
    required String name,
    required String email,
    required String password,
    required String department,
    String? designation,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'department': department.trim(),
      'branch': department.trim(),
      'program': 'FACULTY',
      'role': 'FACULTY',
      if (designation != null && designation.trim().isNotEmpty)
        'designation': designation.trim(),
    };

    // 1. Try primary faculty endpoint (/auth/register/faculty)
    try {
      final url = ApiConfig.getUri('/auth/register/faculty');
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
      if (e.statusCode != 404) {
        return {'success': false, 'message': e.message};
      }
    } catch (_) {}

    // 2. Fallback to /auth/register/student endpoint
    try {
      final url = ApiConfig.getUri('/auth/register/student');
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

  /// Smart multi-endpoint login: tries faculty → external → student in order
  /// so that any registered user type can log in from the single login screen.
  Future<Map<String, dynamic>> login(String email, String password,
      {bool isAdmin = false}) async {
    if (isAdmin) {
      return loginAdmin(email, password);
    }

    String? lastError;

    // 1. Try /auth/login/faculty (for faculty registered accounts)
    try {
      final url = ApiConfig.getUri('/auth/login/faculty');
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
      if (e.statusCode != 404 && e.statusCode != 401) {
        return {'success': false, 'message': e.message};
      }
      lastError = e.message;
    } catch (_) {}

    // 2. Try /auth/login/external (for externals registered with password)
    try {
      final url = ApiConfig.getUri('/auth/login/external');
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
      if (e.statusCode != 404 && e.statusCode != 401) {
        return {'success': false, 'message': e.message};
      }
      lastError = e.message;
    } catch (_) {}

    // 3. Fallback to /auth/login/student (default for students and any unified endpoint)
    final studentRes = await loginStudent(email, password);
    if (studentRes['success'] == true) return studentRes;

    return {
      'success': false,
      'message': studentRes['message'] ?? lastError ?? 'Invalid credentials',
    };
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
}
