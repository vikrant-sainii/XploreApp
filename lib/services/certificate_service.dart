import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class CertificateService {
  Future<Map<String, dynamic>> saveTemplate(String eventId, Map<String, dynamic> templateData) async {
    final url = ApiConfig.getUri('/certificates/$eventId/template');
    final response = await http.post(
      url,
      headers: await ApiConfig.getHeaders(requireAuth: true),
      body: jsonEncode(templateData),
    );
    final data = ApiConfig.handleResponse(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  Future<Uint8List> downloadCertificate(String eventId) async {
    final url = ApiConfig.getUri('/certificates/$eventId/download');
    final response = await http.get(url, headers: await ApiConfig.getHeaders(requireAuth: true));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      ApiConfig.handleResponse(response);
      throw ApiException('Failed to download certificate');
    }
  }
}
