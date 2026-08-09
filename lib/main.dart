import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/blocs/notification/notification_bloc.dart';
import 'package:xplore_app/blocs/participation/participation_bloc.dart';
import 'package:xplore_app/blocs/team/team_bloc.dart';
import 'package:xplore_app/blocs/lost_found/lost_found_bloc.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';
import 'package:xplore_app/screens/head/head_portal_screen.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/services/auth_service.dart';

void main() {
  final authService = AuthService();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authService: authService)..add(CheckSession())),
        BlocProvider<ClubBloc>(
            create: (context) => ClubBloc()..add(FetchUserClubs())),
        BlocProvider<EventBloc>(
            create: (context) => EventBloc()..add(FetchAllEvents())),
        BlocProvider<HeadBloc>(create: (context) => HeadBloc()),
        BlocProvider<NotificationBloc>(create: (context) => NotificationBloc()),
        BlocProvider<ParticipationBloc>(create: (context) => ParticipationBloc()),
        BlocProvider<TeamBloc>(create: (context) => TeamBloc()),
        BlocProvider<LostFoundBloc>(create: (context) => LostFoundBloc()),
      ],
      child: MaterialApp(
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              if (state.role == 'club') {
                return const HeadPortalScreen();
              } else {
                return const UserPortalScreen();
              }
            }
            if (state is AuthInitial || state is AuthLoading) {
              return Scaffold(
                backgroundColor: AppColors.scaffoldBackground,
                body: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return const LoginScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
      ),
    );
  }
}
