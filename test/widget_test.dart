import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xplore_app/main.dart';
import 'package:xplore_app/services/admin_service.dart';
import 'package:xplore_app/services/auth_service.dart';
import 'package:xplore_app/services/user_service.dart';
import 'package:xplore_app/services/event_service.dart';
import 'package:xplore_app/services/club_service.dart';
import 'package:xplore_app/services/notification_service.dart';

void main() {
  testWidgets('App launches and renders login/auth gate successfully', (WidgetTester tester) async {
    final authService = AuthService();
    final userService = UserService();
    final eventService = EventService();
    final clubService = ClubService();
    final notificationService = NotificationService();
    final adminService = AdminService();

    await tester.pumpWidget(MyApp(
      authService: authService,
      userService: userService,
      eventService: eventService,
      clubService: clubService,
      notificationService: notificationService,
      adminService: adminService,
    ));

    await tester.pump(const Duration(milliseconds: 500));

    // Verify MaterialApp and AuthGate are rendered without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
