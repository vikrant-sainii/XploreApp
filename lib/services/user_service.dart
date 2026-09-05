import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';

class UserService {
  Future<UserModel> getMe() async {
    final url = ApiConfig.getUri('/users/me');
    final response = await http.get(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
    );

    final data = ApiConfig.handleResponse(response);
    if (data is Map<String, dynamic>) {
      final userMap = data['user'] is Map<String, dynamic> ? data['user'] : data;
      if (data['role'] != null && userMap['role'] == null) {
        userMap['role'] = data['role'];
      }
      if (data['userType'] != null && userMap['userType'] == null) {
        userMap['userType'] = data['userType'];
      }
      return UserModel.fromJson(userMap);
    }
    throw ApiException('Invalid response format from /api/users/me');
  }

  Future<UserModel> updateProfile({
    required String role,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = ApiConfig.getUri('/users/$id');
      final response = await http.put(
        url,
        headers: await ApiConfig.getHeaders(requireAuth: true),
        body: jsonEncode(data),
      );

      final resData = ApiConfig.handleResponse(response);
      if (resData is Map<String, dynamic>) {
        final userMap = resData['user'] is Map<String, dynamic> ? resData['user'] : resData;
        return UserModel.fromJson(userMap);
      }
    } catch (_) {
      try {
        final url2 = ApiConfig.getUri('/users/$role/$id');
        final response2 = await http.put(
          url2,
          headers: await ApiConfig.getHeaders(requireAuth: true),
          body: jsonEncode(data),
        );

        final resData2 = ApiConfig.handleResponse(response2);
        if (resData2 is Map<String, dynamic>) {
          final userMap = resData2['user'] is Map<String, dynamic> ? resData2['user'] : resData2;
          return UserModel.fromJson(userMap);
        }
      } catch (_) {
        try {
          final url3 = ApiConfig.getUri('/users/profile');
          final response3 = await http.put(
            url3,
            headers: await ApiConfig.getHeaders(requireAuth: true),
            body: jsonEncode(data),
          );

          final resData3 = ApiConfig.handleResponse(response3);
          if (resData3 is Map<String, dynamic>) {
            final userMap = resData3['user'] is Map<String, dynamic> ? resData3['user'] : resData3;
            return UserModel.fromJson(userMap);
          }
        } catch (_) {}
      }
    }
    return getMe();
  }
}
