import 'package:flutter_test/flutter_test.dart';
import 'package:xplore_app/main.dart';
import 'package:xplore_app/services/auth_service.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    final authService = AuthService();
    await tester.pumpWidget(MyApp(authService: authService));
  });
}
