import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import './url_builder.dart';
import 'models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _idToken;
  String? _refreshToken;

  void setTokens(String? idToken, String? refreshToken) {
    _idToken = idToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _idToken = null;
    _refreshToken = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_idToken != null) 'Authorization': 'Bearer $_idToken',
      };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (kDebugMode) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else {
      String errorMessage;
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Unknown error occurred';
      } catch (e) {
        errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // Authentication
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse(UrlBuilder.signup),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    final data = await _handleResponse(response);
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(UrlBuilder.login),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = await _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data);
    
    if (authResponse.idToken != null && authResponse.refreshToken != null) {
      setTokens(authResponse.idToken, authResponse.refreshToken);
    }
    
    return authResponse;
  }

  // Events
  Future<Event> createEvent({
    required String name,
    required DateTime eventDate,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse(UrlBuilder.events),
      headers: _headers,
      body: json.encode({
        'name': name,
        'event_date': eventDate.toIso8601String().split('T')[0],
        'description': description,
      }),
    );

    final data = await _handleResponse(response);
    return Event.fromJson(data);
  }

  Future<List<Event>> getEvents() async {
    final response = await http.get(
      Uri.parse(UrlBuilder.events),
      headers: _headers,
    );

    final data = await _handleResponse(response);
    return (data as List).map((event) => Event.fromJson(event)).toList();
  }

  Future<Map<String, dynamic>> participateInEvent(String eventId) async {
    final response = await http.post(
      Uri.parse(UrlBuilder.eventParticipate(eventId)),
      headers: _headers,
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> leaveEvent(String eventId) async {
    final response = await http.post(
      Uri.parse(UrlBuilder.eventLeave(eventId)),
      headers: _headers,
    );

    return await _handleResponse(response);
  }

  // Users
  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse(UrlBuilder.userMe),
      headers: _headers,
    );

    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  Future<User> updateCurrentUser({
    String? name,
    int? rollno,
    String? branch,
    String? hostelName,
    String? roomNo,
    String? skills,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (rollno != null) body['rollno'] = rollno;
    if (branch != null) body['branch'] = branch;
    if (hostelName != null) body['hostelName'] = hostelName;
    if (roomNo != null) body['roomNo'] = roomNo;
    if (skills != null) body['skills'] = skills;

    final response = await http.put(
      Uri.parse(UrlBuilder.userMe),
      headers: _headers,
      body: json.encode(body),
    );

    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  Future<User> getUserById(String userId) async {
    final response = await http.get(
      Uri.parse(UrlBuilder.userById(userId)),
      headers: _headers,
    );

    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  Future<Map<String, dynamic>> getWelcomeMessage() async {
    final response = await http.get(
      Uri.parse(UrlBuilder.root),
      headers: {'Content-Type': 'application/json'},
    );

    return await _handleResponse(response);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
