import 'package:flutter/material.dart';
import 'package:xplore_app/screens/user/user_registered_events_screen.dart';
import 'package:xplore_app/screens/user/user_upcoming_events_screen.dart';
import 'package:xplore_app/screens/user/user_home_screen.dart';
import 'package:xplore_app/screens/user/user_profile_screen.dart';
import 'package:xplore_app/config/theme.dart';

class UserPortalScreen extends StatefulWidget {
  const UserPortalScreen({super.key});

  @override
  State<UserPortalScreen> createState() => _UserPortalScreenState();
}

class _UserPortalScreenState extends State<UserPortalScreen> {
  int currentindex = 0;

  //general function to call back
  void _modifyindex(int index) {
    setState(() {
      currentindex = index;
    });
  }

  late final List<Widget> screen = [
    UserHomeScreen(changeindex: _modifyindex,),
    UserRegisteredEventsScreen(changeindex: _modifyindex),
    UserUpcomingEventsScreen(changeindex: _modifyindex),
    UserProfileScreen(changeindex: _modifyindex),
  ];

  @override
  void initState() {
    super.initState();
    currentindex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: currentindex,
            children: screen,
          ),
          CustomBottomNavBar(
            currentindex: currentindex,
            onTap: _modifyindex,
          ),
        ],
      ),
    );
  }
}

//bottomnavigationbar
class CustomBottomNavBar extends StatelessWidget {
  final int currentindex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentindex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => onTap(0),
              icon: const Icon(Icons.home_rounded),
              iconSize: 28,
              color: (currentindex == 0) ? AppColors.primary : AppColors.textSecondary,
              tooltip: 'Home',
            ),
            IconButton(
              onPressed: () => onTap(1),
              icon: const Icon(Icons.event_available_rounded),
              iconSize: 28,
              color: (currentindex == 1) ? AppColors.primary : AppColors.textSecondary,
              tooltip: 'Registered Events',
            ),
            IconButton(
              onPressed: () => onTap(2),
              icon: const Icon(Icons.calendar_month_rounded),
              iconSize: 28,
              color: (currentindex == 2) ? AppColors.primary : AppColors.textSecondary,
              tooltip: 'Upcoming Events',
            ),
            IconButton(
              onPressed: () => onTap(3),
              icon: const Icon(Icons.person_rounded),
              iconSize: 28,
              color: (currentindex == 3) ? AppColors.primary : AppColors.textSecondary,
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
