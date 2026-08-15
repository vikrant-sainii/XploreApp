import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xplore_app/screens/user/notifications_screen.dart';
import 'package:xplore_app/screens/user/lost_found_screen.dart';
import 'package:xplore_app/screens/user/user_clubs_screen.dart';

PreferredSizeWidget customAppBar(double width, BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_rounded,
              size: 30,
              color: Colors.white,
            ),
            SizedBox(width: width * 0.03),
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: width * 0.1),
            IconButton(
              iconSize: 24,
              icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
              tooltip: "Announcements",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            IconButton(
              iconSize: 24,
              icon: const Icon(FontAwesomeIcons.boxOpen, color: Colors.white, size: 20),
              tooltip: "Lost & Found",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LostFoundScreen()),
                );
              },
            ),
            IconButton(
              iconSize: 24,
              icon: const Icon(Icons.apps_rounded, color: Colors.white),
              tooltip: "My Clubs",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserClubsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
