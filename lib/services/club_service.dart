import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/club_model.dart';
import 'secure_storage_service.dart';

class ClubService {
  static String get baseUrl => '${EnvConfig.baseUrl}/clubs';
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/clubs - Get all clubs
  Future<List<ClubModel>> getClubs() async {
    final url = Uri.parse(baseUrl);
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClubModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load clubs');
      }
    } catch (e) {
      throw Exception('Error loading clubs: $e');
    }
  }

  // GET /api/clubs/:idOrSlug - Get details of a single club
  Future<ClubModel> getClubDetails(String idOrSlug) async {
    final url = Uri.parse('$baseUrl/$idOrSlug');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClubModel.fromJson(data);
      } else {
        throw Exception('Failed to load club details');
      }
    } catch (e) {
      throw Exception('Error loading club details: $e');
    }
  }
}
