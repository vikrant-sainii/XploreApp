import 'api_config.dart';

class UrlBuilder {
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Authentication endpoints
  static String get signup => '$baseUrl/signup';
  static String get login => '$baseUrl/login';
  
  // Event endpoints
  static String get events => '$baseUrl/events';
  static String eventParticipate(String eventId) => '$baseUrl/events/$eventId/participate';
  static String eventLeave(String eventId) => '$baseUrl/events/$eventId/leave';
  
  // User endpoints
  static String get userMe => '$baseUrl/users/me';
  static String userById(String userId) => '$baseUrl/users/$userId';
  
  // Root endpoint
  static String get root => baseUrl;
}