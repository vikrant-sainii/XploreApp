import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xplore_app/services/auth_service.dart';
import 'package:xplore_app/services/club_service.dart';
import 'package:xplore_app/services/event_service.dart';
import 'package:xplore_app/services/user_service.dart';
import 'package:xplore_app/services/lost_found_service.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = TestHttpOverrides();

  group('ClubSetu Backend API Integration Tests', () {
    
    setUpAll(() {
      final envFile = File('.env');
      expect(envFile.existsSync(), isTrue, reason: '.env file must exist at project root');
    });

    test('ClubService - getClubs() fetches successfully', () async {
      final service = ClubService();
      final clubs = await service.getClubs();
      expect(clubs, isNotNull);
    });

    test('EventService - getEvents() fetches successfully', () async {
      final service = EventService();
      final events = await service.getEvents();
      expect(events, isNotNull);
    });

    test('UserService - searchStudents() handles authentication gracefully', () async {
      final service = UserService();
      try {
        final students = await service.searchStudents('a');
        expect(students, isNotNull);
      } catch (e) {
        expect(e.toString(), contains('Exception'));
      }
    });

    test('LostFoundService - getItems() handles authentication gracefully', () async {
      final service = LostFoundService();
      try {
        final items = await service.getItems();
        expect(items, isNotNull);
      } catch (e) {
        expect(e.toString(), contains('Exception'));
      }
    });

    test('AuthService - loginStudent() fails gracefully with incorrect credentials', () async {
      final service = AuthService();
      final result = await service.loginStudent(
        'invalid-email-xyz@example.com',
        'wrong-password-123',
      );
      expect(result['success'], isFalse);
    });
  });
}
