import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/blocs/notification/notification_bloc.dart';
import 'package:xplore_app/screens/admin/admin_dashboard_screen.dart';
import 'package:xplore_app/screens/head/head_portal_screen.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';
import 'package:xplore_app/services/admin_service.dart';
import 'package:xplore_app/services/auth_service.dart';
import 'package:xplore_app/services/club_service.dart';
import 'package:xplore_app/services/event_service.dart';
import 'package:xplore_app/services/notification_service.dart';
import 'package:xplore_app/services/user_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final userService = UserService();
  final eventService = EventService();
  final clubService = ClubService();
  final notificationService = NotificationService();
  final adminService = AdminService();

  runApp(MyApp(
    authService: authService,
    userService: userService,
    eventService: eventService,
    clubService: clubService,
    notificationService: notificationService,
    adminService: adminService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final UserService userService;
  final EventService eventService;
  final ClubService clubService;
  final NotificationService notificationService;
  final AdminService adminService;

  const MyApp({
    super.key,
    required this.authService,
    required this.userService,
    required this.eventService,
    required this.clubService,
    required this.notificationService,
    required this.adminService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: authService,
            userService: userService,
          )..add(CheckAuthStatus()),
        ),
        BlocProvider<ClubBloc>(
          create: (context) => ClubBloc(
            clubService: clubService,
          )..add(FetchAllClubs()),
        ),
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(
            eventService: eventService,
          )..add(const FetchAllEvents()),
        ),
        BlocProvider<HeadBloc>(
          create: (context) => HeadBloc(
            eventService: eventService,
            clubService: clubService,
            notificationService: notificationService,
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            notificationService: notificationService,
          )..add(const FetchNotifications()),
        ),
        BlocProvider<AdminBloc>(
          create: (context) => AdminBloc(
            adminService: adminService,
          )..add(const FetchAdminStats()),
        ),
      ],
      child: MaterialApp(
        title: 'ClubSetu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F7FA),
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF191C32),
            primary: const Color(0xFF191C32),
            secondary: const Color(0xFFF7931A),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<EventBloc>().add(FetchAllEvents(userId: state.user.id));
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          final roleUpper = user.role.toUpperCase();
          final userTypeLower = (user.userType ?? '').toLowerCase();

          if (user.isAdmin ||
              roleUpper == 'ADMIN' ||
              roleUpper == 'PLATFORMADMIN' ||
              roleUpper == 'FACULTYCOORDINATOR' ||
              roleUpper == 'FACULTY_COORDINATOR' ||
              roleUpper == 'FACULTY' ||
              roleUpper == 'LOSTFOUNDADMIN' ||
              roleUpper == 'PAYMENTADMIN' ||
              userTypeLower == 'admin') {
            return const AdminDashboardScreen();
          } else if (user.isClubAccount ||
                     roleUpper == 'CLUB_ACCOUNT' ||
                     userTypeLower == 'club_account') {
            return const HeadPortalScreen();
          }
          return const UserPortalScreen();
        } else if (state is AuthLoading && state is! AuthNeeds2FA) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
