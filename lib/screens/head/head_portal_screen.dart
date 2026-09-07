import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/screens/head/head_dashboard_screen.dart';
import 'package:xplore_app/screens/head/head_add_event_screen.dart';
import 'package:xplore_app/screens/head/head_event_management_screen.dart';
import 'package:xplore_app/screens/user/club_details_screen.dart';
import 'package:xplore_app/screens/user/user_profile_screen.dart';

class HeadPortalScreen extends StatefulWidget {
  final int initialIndex;
  final String? clubId;
  final String? clubName;

  const HeadPortalScreen({
    super.key,
    this.initialIndex = 0,
    this.clubId,
    this.clubName,
  });

  @override
  State<HeadPortalScreen> createState() => _HeadPortalScreenState();
}

class _HeadPortalScreenState extends State<HeadPortalScreen> {
  late int currentindex;

  void _modifyindex(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    currentindex = widget.initialIndex;
    context.read<ClubBloc>().add(FetchAllClubs());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? user;
    if (authState is Authenticated) {
      user = authState.user;
    }

    final bool isOfficialClub = user?.isClubAccount == true;

    ClubModel? matchedClub;
    if (user != null) {
      final clubState = context.watch<ClubBloc>().state;
      List<ClubModel> allClubs = [];
      if (clubState is ClubsLoaded) {
        allClubs = clubState.allClubs.isNotEmpty ? clubState.allClubs : clubState.clubs;
      }

      matchedClub = allClubs.where((c) {
        if (user!.clubId != null && user.clubId == c.id) return true;
        if (c.name.toLowerCase().trim() == user.name.toLowerCase().trim()) return true;
        if (c.clubEmail != null && c.clubEmail!.toLowerCase().trim() == user.email.toLowerCase().trim()) return true;
        return false;
      }).firstOrNull;

      matchedClub ??= ClubModel(
        id: user.clubId ?? 'club_${user.name.toLowerCase()}',
        name: user.name,
        slug: user.name.toLowerCase().replaceAll(' ', '-'),
        description: "The official student group dedicated to community, innovation, and campus spirit.",
        category: "STUDENT",
        image: user.profileImage ?? 'assets/gdgc.png',
        clubEmail: user.email,
        role: 'HEAD',
      );
    }

    final List<Widget> screens = [
      HeadDashboardScreen(
        clubId: widget.clubId,
        clubName: widget.clubName,
        changeindex: _modifyindex,
      ),
      HeadAddEventScreen(
        clubId: widget.clubId,
        clubName: widget.clubName,
        changeindex: _modifyindex,
      ),
      isOfficialClub && matchedClub != null
          ? ClubDetailsScreen(club: matchedClub, changeindex: _modifyindex)
          : HeadEventManagementScreen(
              clubId: widget.clubId,
              clubName: widget.clubName,
              changeindex: _modifyindex,
            ),
      UserProfileScreen(changeindex: _modifyindex),
    ];

    final int safeIndex = currentindex >= screens.length ? 0 : currentindex;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: Stack(
        children: [
          screens[safeIndex],
          CustomBottomNavBar(
            currentindex: safeIndex,
            onTap: _modifyindex,
            isOfficialClub: isOfficialClub,
          ),
        ],
      ),
    );
  }
}

// bottomnavigationbar
class CustomBottomNavBar extends StatelessWidget {
  final int currentindex;
  final Function(int) onTap;
  final bool isOfficialClub;

  const CustomBottomNavBar({
    super.key,
    required this.currentindex,
    required this.onTap,
    this.isOfficialClub = false,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.69),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => onTap(0),
              icon: const Icon(Icons.home),
              iconSize: 30,
              color: (currentindex == 0) ? Colors.black : Colors.grey,
            ),
            IconButton(
              onPressed: () => onTap(1),
              icon: SvgPicture.asset(
                'assets/icons/homenav.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  (currentindex == 1) ? Colors.black : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            IconButton(
              onPressed: () => onTap(2),
              icon: Icon(isOfficialClub ? Icons.visibility : Icons.group),
              iconSize: 30,
              color: (currentindex == 2) ? Colors.black : Colors.grey,
            ),
            IconButton(
              onPressed: () => onTap(3),
              icon: const Icon(Icons.person),
              iconSize: 30,
              color: (currentindex == 3) ? Colors.black : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
