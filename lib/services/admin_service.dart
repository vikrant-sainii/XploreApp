import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'secure_storage_service.dart';

class AdminService {
  static String get baseUrl => '${EnvConfig.baseUrl}/admin';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/admin/dashboard-stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('$baseUrl/dashboard-stats');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'stats': jsonDecode(response.body) as Map<String, dynamic>,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load dashboard stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET /api/admin/manual-payments
  Future<List<dynamic>> getManualPayments() async {
    final url = Uri.parse('$baseUrl/manual-payments');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load manual payments');
      }
    } catch (e) {
      throw Exception('Error loading manual payments: $e');
    }
  }

  // POST /api/admin/clubs
  Future<Map<String, dynamic>> createClub(Map<String, dynamic> clubData) async {
    final url = Uri.parse('$baseUrl/clubs');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(clubData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'club': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create club'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT /api/admin/clubs/:id
  Future<Map<String, dynamic>> updateClub(String id, Map<String, dynamic> clubData) async {
    final url = Uri.parse('$baseUrl/clubs/$id');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(clubData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'club': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to update club'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET /api/admin/coordinators
  Future<List<dynamic>> getCoordinators() async {
    final url = Uri.parse('$baseUrl/coordinators');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load coordinators');
      }
    } catch (e) {
      throw Exception('Error loading coordinators: $e');
    }
  }

  // POST /api/admin/coordinators
  Future<Map<String, dynamic>> createCoordinator(Map<String, dynamic> coordinatorData) async {
    final url = Uri.parse('$baseUrl/coordinators');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(coordinatorData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'coordinator': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create coordinator'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT /api/admin/coordinators/:id
  Future<Map<String, dynamic>> updateCoordinator(String id, Map<String, dynamic> coordinatorData) async {
    final url = Uri.parse('$baseUrl/coordinators/$id');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(coordinatorData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'coordinator': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to update coordinator'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
