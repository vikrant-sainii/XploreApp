import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/lost_found_model.dart';
import 'secure_storage_service.dart';

class LostFoundService {
  static String get baseUrl => '${EnvConfig.baseUrl}/lost-found';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/lost-found
  Future<List<LostFoundModel>> getItems() async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LostFoundModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lost and found items');
      }
    } catch (e) {
      throw Exception('Error loading lost and found items: $e');
    }
  }

  // GET /api/lost-found/my-posts
  Future<List<LostFoundModel>> getMyPosts() async {
    final url = Uri.parse('$baseUrl/my-posts');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LostFoundModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load my lost and found posts');
      }
    } catch (e) {
      throw Exception('Error loading my lost and found posts: $e');
    }
  }

  // POST /api/lost-found
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String description,
    required String type, // "LOST" or "FOUND"
    String? imageUrl,
    String? imagePublicId,
    String? whatsapp,
  }) async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    final body = {
      'title': title,
      'description': description,
      'type': type == 'Found' ? 'Found' : 'Lost', // matches server checks
      if (imageUrl != null) 'image_url': imageUrl,
      if (imagePublicId != null) 'image_public_id': imagePublicId,
      if (whatsapp != null) 'whatsapp': whatsapp,
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Post created successfully',
          'post': LostFoundModel.fromJson(data['post']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create post',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // PATCH /api/lost-found/:id/reunite
  Future<Map<String, dynamic>> reunite(String id) async {
    final url = Uri.parse('$baseUrl/$id/reunite');
    final headers = await _getHeaders();
    try {
      final response = await http.patch(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Item marked as reunited',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update item status',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/lost-found/:id/report
  Future<Map<String, dynamic>> reportPost(String id, String reason) async {
    final url = Uri.parse('$baseUrl/$id/report');
    final headers = await _getHeaders();
    final body = {'reason': reason};
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Report submitted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit report',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/lost-found/:id/claim
  Future<Map<String, dynamic>> claimPost(String id) async {
    final url = Uri.parse('$baseUrl/$id/claim');
    final headers = await _getHeaders();
    try {
      final response = await http.post(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Claim requested successfully',
          'contact': data['contact'] as Map<String, dynamic>?,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to request claim',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST /api/lost-found/:id/report-liar
  Future<Map<String, dynamic>> reportLiar(String id, String liarId, String reason) async {
    final url = Uri.parse('$baseUrl/$id/report-liar');
    final headers = await _getHeaders();
    final body = {'liarId': liarId, 'reason': reason};
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'User reported and restricted',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to report liar',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
