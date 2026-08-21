import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'secure_storage_service.dart';

class AdminService {
  static String get baseUrl => '${EnvConfig.baseUrl}/admin';
  static String get notificationsUrl => '${EnvConfig.baseUrl}/notifications';
  static String get venuesUrl => '${EnvConfig.baseUrl}/venues';

  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    if (kDebugMode) {
      debugPrint('🔑 [AdminService] Token present: ${token != null && token.isNotEmpty}');
    }
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _logError(String label, Uri url, int statusCode, String body) {
    debugPrint('❌ [ADMIN API ERROR] [$label]');
    debugPrint('   URL: $url');
    debugPrint('   Status: $statusCode');
    debugPrint('   Response Body: $body');
  }

  void _logException(String label, Uri url, dynamic error) {
    debugPrint('💥 [ADMIN API EXCEPTION] [$label]');
    debugPrint('   URL: $url');
    debugPrint('   Error: $error');
  }

  void _logSuccess(String label, Uri url) {
    if (kDebugMode) {
      debugPrint('✅ [ADMIN API SUCCESS] [$label] $url');
    }
  }

  // ─── DASHBOARD STATS ───────────────────────────────────────────────────────
  // GET /api/admin/dashboard-stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('$baseUrl/dashboard-stats');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getDashboardStats', url);
        return {
          'success': true,
          'stats': jsonDecode(response.body) as Map<String, dynamic>,
        };
      } else {
        _logError('getDashboardStats', url, response.statusCode, response.body);
        Map<String, dynamic> data = {};
        try {
          data = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load dashboard stats (${response.statusCode})',
        };
      }
    } catch (e) {
      _logException('getDashboardStats', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── EVENT DATA ────────────────────────────────────────────────────────────
  // GET /api/admin/event-data-export
  Future<List<dynamic>> getEventData({Map<String, String>? filters}) async {
    var queryParams = filters ?? {};
    final url = Uri.parse('$baseUrl/event-data-export').replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getEventData', url);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['events'] as List<dynamic>? ?? [];
      } else {
        _logError('getEventData', url, response.statusCode, response.body);
        throw Exception('Failed to load event data (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getEventData', url, e);
      throw Exception('Error loading event data: $e');
    }
  }

  // ─── CLUBS LIST ────────────────────────────────────────────────────────────
  // GET /api/admin/clubs-list
  Future<List<dynamic>> getClubsList() async {
    final url = Uri.parse('$baseUrl/clubs-list');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getClubsList', url);
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        _logError('getClubsList', url, response.statusCode, response.body);
        throw Exception('Failed to load clubs (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getClubsList', url, e);
      throw Exception('Error loading clubs: $e');
    }
  }

  // ─── CREATE CLUB ───────────────────────────────────────────────────────────
  // POST /api/admin/clubs
  Future<Map<String, dynamic>> createClub(Map<String, dynamic> clubData) async {
    final url = Uri.parse('$baseUrl/clubs');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] POST $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(clubData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logSuccess('createClub', url);
        final data = jsonDecode(response.body);
        return {'success': true, 'club': data};
      } else {
        _logError('createClub', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create club'};
      }
    } catch (e) {
      _logException('createClub', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── UPDATE CLUB ───────────────────────────────────────────────────────────
  // PUT /api/admin/clubs/:id
  Future<Map<String, dynamic>> updateClub(String id, Map<String, dynamic> clubData) async {
    final url = Uri.parse('$baseUrl/clubs/$id');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] PUT $url');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(clubData),
      );
      if (response.statusCode == 200) {
        _logSuccess('updateClub', url);
        final data = jsonDecode(response.body);
        return {'success': true, 'club': data};
      } else {
        _logError('updateClub', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update club'};
      }
    } catch (e) {
      _logException('updateClub', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── COORDINATORS ──────────────────────────────────────────────────────────
  // GET /api/admin/coordinators
  Future<List<dynamic>> getCoordinators() async {
    final url = Uri.parse('$baseUrl/coordinators');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getCoordinators', url);
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        _logError('getCoordinators', url, response.statusCode, response.body);
        throw Exception('Failed to load coordinators (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getCoordinators', url, e);
      throw Exception('Error loading coordinators: $e');
    }
  }

  // POST /api/admin/coordinators
  Future<Map<String, dynamic>> createCoordinator(Map<String, dynamic> coordinatorData) async {
    final url = Uri.parse('$baseUrl/coordinators');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] POST $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(coordinatorData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logSuccess('createCoordinator', url);
        final data = jsonDecode(response.body);
        return {'success': true, 'coordinator': data};
      } else {
        _logError('createCoordinator', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create coordinator'};
      }
    } catch (e) {
      _logException('createCoordinator', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT /api/admin/coordinators/:id
  Future<Map<String, dynamic>> updateCoordinator(String id, Map<String, dynamic> coordinatorData) async {
    final url = Uri.parse('$baseUrl/coordinators/$id');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] PUT $url');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(coordinatorData),
      );
      if (response.statusCode == 200) {
        _logSuccess('updateCoordinator', url);
        final data = jsonDecode(response.body);
        return {'success': true, 'coordinator': data};
      } else {
        _logError('updateCoordinator', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update coordinator'};
      }
    } catch (e) {
      _logException('updateCoordinator', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── MANUAL PAYMENTS ───────────────────────────────────────────────────────
  // GET /api/admin/manual-payments
  Future<List<dynamic>> getManualPayments() async {
    final url = Uri.parse('$baseUrl/manual-payments');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getManualPayments', url);
        final data = jsonDecode(response.body);
        if (data is List) return data;
        return data['participations'] as List<dynamic>? ?? [];
      } else {
        _logError('getManualPayments', url, response.statusCode, response.body);
        throw Exception('Failed to load manual payments (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getManualPayments', url, e);
      throw Exception('Error loading manual payments: $e');
    }
  }

  // GET /api/admin/manual-payments (with summary)
  Future<Map<String, dynamic>> getManualPaymentsWithSummary() async {
    final url = Uri.parse('$baseUrl/manual-payments');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getManualPaymentsWithSummary', url);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'participations': data['participations'] as List<dynamic>? ?? [],
          'summary': data['summary'] as Map<String, dynamic>?,
        };
      } else {
        _logError('getManualPaymentsWithSummary', url, response.statusCode, response.body);
        throw Exception('Failed to load manual payments (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getManualPaymentsWithSummary', url, e);
      throw Exception('Error loading manual payments: $e');
    }
  }

  // ─── VENUES ────────────────────────────────────────────────────────────────
  // GET /api/venues
  Future<List<dynamic>> getVenues() async {
    final url = Uri.parse(venuesUrl);
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getVenues', url);
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        _logError('getVenues', url, response.statusCode, response.body);
        throw Exception('Failed to load venues (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getVenues', url, e);
      throw Exception('Error loading venues: $e');
    }
  }

  // POST /api/venues
  Future<Map<String, dynamic>> createVenue(Map<String, dynamic> venueData) async {
    final url = Uri.parse(venuesUrl);
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] POST $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(venueData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logSuccess('createVenue', url);
        final data = jsonDecode(response.body);
        return {'success': true, 'venue': data};
      } else {
        _logError('createVenue', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create venue'};
      }
    } catch (e) {
      _logException('createVenue', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT /api/venues/:id
  Future<Map<String, dynamic>> updateVenue(String id, Map<String, dynamic> venueData) async {
    final url = Uri.parse('$venuesUrl/$id');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] PUT $url');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(venueData),
      );
      if (response.statusCode == 200) {
        _logSuccess('updateVenue', url);
        final data = jsonDecode(response.body);
        return {'success': true, 'venue': data};
      } else {
        _logError('updateVenue', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update venue'};
      }
    } catch (e) {
      _logException('updateVenue', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // DELETE /api/venues/:id
  Future<Map<String, dynamic>> deleteVenue(String id) async {
    final url = Uri.parse('$venuesUrl/$id');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] DELETE $url');
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('deleteVenue', url);
        return {'success': true};
      } else {
        _logError('deleteVenue', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to delete venue'};
      }
    } catch (e) {
      _logException('deleteVenue', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── NOTIFICATIONS / BROADCASTS ────────────────────────────────────────────
  // GET /api/notifications/sent
  Future<List<dynamic>> getSentBroadcasts() async {
    final url = Uri.parse('$notificationsUrl/sent');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getSentBroadcasts', url);
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        _logError('getSentBroadcasts', url, response.statusCode, response.body);
        throw Exception('Failed to load broadcasts (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getSentBroadcasts', url, e);
      throw Exception('Error loading broadcasts: $e');
    }
  }

  // GET /api/notifications
  Future<List<dynamic>> getAdminNotifications() async {
    final url = Uri.parse(notificationsUrl);
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] GET $url');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('getAdminNotifications', url);
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        _logError('getAdminNotifications', url, response.statusCode, response.body);
        throw Exception('Failed to load notifications (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _logException('getAdminNotifications', url, e);
      throw Exception('Error loading notifications: $e');
    }
  }

  // POST /api/notifications
  Future<Map<String, dynamic>> sendBroadcast(Map<String, dynamic> broadcastData) async {
    final url = Uri.parse(notificationsUrl);
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] POST $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(broadcastData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logSuccess('sendBroadcast', url);
        return {'success': true};
      } else {
        _logError('sendBroadcast', url, response.statusCode, response.body);
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to send broadcast'};
      }
    } catch (e) {
      _logException('sendBroadcast', url, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT /api/notifications/read-all
  Future<void> markAllNotificationsRead() async {
    final url = Uri.parse('$notificationsUrl/read-all');
    final headers = await _getHeaders();
    try {
      debugPrint('🚀 [AdminService] PUT $url');
      final response = await http.put(url, headers: headers);
      if (response.statusCode == 200) {
        _logSuccess('markAllNotificationsRead', url);
      } else {
        _logError('markAllNotificationsRead', url, response.statusCode, response.body);
      }
    } catch (e) {
      _logException('markAllNotificationsRead', url, e);
    }
  }
}
