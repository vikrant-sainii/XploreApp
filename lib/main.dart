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
// import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/register_screen.dart';
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
            create: (context) => AuthBloc(authService: authService)),
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
      child: const MaterialApp(
        home: RegisterScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
