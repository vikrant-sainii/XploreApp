import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/notification/notification_bloc.dart';
import 'package:xplore_app/models/club_model.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/screens/user/club_details_screen.dart';
import 'package:xplore_app/screens/user/user_event_details_screen.dart';
import 'package:xplore_app/screens/user/notifications_screen.dart';
import 'package:xplore_app/screens/user/xplore_clubs_popup.dart';
import 'package:xplore_app/screens/head/head_portal_screen.dart';
import 'package:xplore_app/screens/head/head_member_management_screen.dart';

class UserHomeScreen extends StatelessWidget {
  final Function(int) changeindex;
  const UserHomeScreen({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? user;
    if (authState is Authenticated) {
      user = authState.user;
      final userId = user.id;
      if (userId.isNotEmpty) {
        final eventBloc = context.read<EventBloc>();
        if (eventBloc.state is! EventsLoaded || (eventBloc.state as EventsLoaded).userParticipations.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            eventBloc.add(FetchAllEvents(userId: userId));
          });
        }
      }
    }
    final memberships = user?.memberships ?? [];

    return Scaffold(
      appBar: _buildCustomAppBar(MediaQuery.of(context).size.width, context),
      backgroundColor: const Color(0xFFF7F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: height * 0.03),
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        "assets/welcframe.jpeg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.02,
                    left: width * 0.1,
                    child: ElevatedButton(
                      onPressed: () {
                        XploreClubsPopupDialog.show(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        "Xplore Clubs",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),

              // Registered Events Section
              Container(
                width: width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Color(0xFFF7F7FA),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Registered Events",
                            style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Color(0xFF191C32),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => changeindex(1),
                            child: const Text(
                              "View All",
                              style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: BlocBuilder<EventBloc, EventState>(
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is EventsLoaded) {
                            final registered = state.registeredEvents;
                            if (registered.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Text(
                                    "No registered events yet. Explore below!",
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: registered.length > 2 ? 2 : registered.length,
                              itemBuilder: (BuildContext context, int index) {
                                final event = registered[index];
                                return EventTile(
                                  imagelocation: event.imageLocation,
                                  title: event.title,
                                  subtitle: event.subtitle,
                                  timeText: event.formattedTime,
                                  onTap: () => changeindex(1),
                                  type: TrailingType.typeRegistered,
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // MY JOINED CLUBS SECTION - HORIZONTAL SLIDER / CAROUSEL WITH ARROWS
                    if (memberships.isNotEmpty) ...[
                      MyClubsCarousel(memberships: memberships),
                      SizedBox(height: height * 0.02),
                    ],

                    XploreTile(
                      title: "Xplore All Campus Clubs",
                      onTap: () {
                        XploreClubsPopupDialog.show(context);
                      },
                    ),
                    SizedBox(height: height * 0.02),

                    // Upcoming Events Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Upcoming Events",
                            style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Color(0xFF191C32),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => changeindex(2),
                            child: const Text(
                              "View All",
                              style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: BlocBuilder<EventBloc, EventState>(
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is EventsLoaded) {
                            final upcoming = state.upcomingEvents;
                            if (upcoming.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Text("No upcoming events right now.", style: TextStyle(color: Colors.grey)),
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: upcoming.length > 3 ? 3 : upcoming.length,
                              itemBuilder: (BuildContext context, int index) {
                                final event = upcoming[index];
                                return EventTile(
                                  imagelocation: event.imageLocation,
                                  title: event.title,
                                  subtitle: event.subtitle,
                                  timeText: event.formattedTime,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserEventDetailsScreen(
                                          changeindex: changeindex,
                                          preview: EventDraft.no,
                                          event: event,
                                        ),
                                      ),
                                    );
                                  },
                                  type: TrailingType.typeUpcoming,
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(double width, BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome Home",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191C32),
                ),
              ),
              const Spacer(),
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  int unread = 0;
                  if (state is NotificationsLoaded) unread = state.unreadCount;
                  return Stack(
                    children: [
                      IconButton(
                        iconSize: 24,
                        icon: const Icon(Icons.notifications_none, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7931A),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyClubsCarousel extends StatefulWidget {
  final List<ClubMembershipModel> memberships;

  const MyClubsCarousel({super.key, required this.memberships});

  @override
  State<MyClubsCarousel> createState() => _MyClubsCarouselState();
}

class _MyClubsCarouselState extends State<MyClubsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.memberships.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Clubs & Hub",
                style: TextStyle(
                  letterSpacing: -1,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Color(0xFF191C32),
                ),
              ),
              if (widget.memberships.length > 1)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      color: _currentPage > 0 ? const Color(0xFF191C32) : Colors.grey.shade300,
                      onPressed: _currentPage > 0 ? _prevPage : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${_currentPage + 1}/${widget.memberships.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191C32)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      color: _currentPage < widget.memberships.length - 1 ? const Color(0xFF191C32) : Colors.grey.shade300,
                      onPressed: _currentPage < widget.memberships.length - 1 ? _nextPage : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
            },
            itemCount: widget.memberships.length,
            itemBuilder: (ctx, idx) {
              final m = widget.memberships[idx];
              final String clubName = (m.clubName != null && m.clubName!.isNotEmpty) ? m.clubName! : "Club";
              final String role = m.role.toUpperCase();
              final bool isExecutive = role == 'HEAD' || role == 'CLUB_HEAD' || role == 'COORDINATOR';

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: ClubTile(
                  clubId: m.clubId,
                  clubName: clubName,
                  role: role,
                  isExecutive: isExecutive,
                  onTapDashboard: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HeadPortalScreen(
                          clubId: m.clubId,
                          clubName: clubName,
                        ),
                      ),
                    );
                  },
                  onTapTeam: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HeadMemberManagementScreen(clubId: m.clubId),
                      ),
                    );
                  },
                  onTapDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClubDetailsScreen(
                          club: ClubModel(
                            id: m.clubId,
                            name: clubName,
                            slug: clubName.toLowerCase().replaceAll(' ', '-'),
                            role: role,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ClubTile extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String role;
  final bool isExecutive;
  final VoidCallback onTapDashboard;
  final VoidCallback onTapTeam;
  final VoidCallback onTapDetails;

  const ClubTile({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.role,
    required this.isExecutive,
    required this.onTapDashboard,
    required this.onTapTeam,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Accent Status Indicator
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isExecutive ? const Color(0xFFF7931A) : const Color(0xFF5FC88F),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Avatar + Title + Role Badge
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isExecutive ? const Color(0xFFFFEBE4) : const Color(0xFFDEF5E9),
                          child: Text(
                            clubName.isNotEmpty ? clubName[0] : 'C',
                            style: TextStyle(
                              color: isExecutive ? const Color(0xFFF7931A) : const Color(0xFF5FC88F),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clubName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF191C32),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isExecutive ? const Color(0xFFFFEBE4) : const Color(0xFFDEF5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isExecutive ? "EXECUTIVE LEAD • $role" : "JOINED STUDENT MEMBER",
                                  style: TextStyle(
                                    color: isExecutive ? const Color(0xFFF7931A) : const Color(0xFF5FC88F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Descriptive Subtitle
                    Text(
                      isExecutive
                          ? "Full Management Access • Control Events, Members, Attendance & Payouts"
                          : "Official Joined Member • View Club Updates & Member Feed",
                      style: const TextStyle(color: Colors.black54, fontSize: 11.5, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Quick Action Buttons Row
                    Row(
                      children: [
                        if (isExecutive) ...[
                          ElevatedButton.icon(
                            onPressed: onTapDashboard,
                            icon: const Icon(Icons.dashboard, size: 12, color: Colors.white),
                            label: const Text(
                              "Dashboard",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF191C32),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: onTapTeam,
                            icon: const Icon(Icons.group, size: 12, color: Color(0xFF191C32)),
                            label: const Text(
                              "Team",
                              style: TextStyle(color: Color(0xFF191C32), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: onTapDetails,
                            icon: const Icon(Icons.visibility, size: 12, color: Colors.white),
                            label: const Text(
                              "View Club Page",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5FC88F),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum TrailingType { typeUpcoming, typeRegistered }

Widget buildTrailing(TrailingType type, VoidCallback? onTap, {String timeText = "5:30 PM"}) {
  switch (type) {
    case TrailingType.typeUpcoming:
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(timeText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "See More Info",
                  style: TextStyle(letterSpacing: -0.5, fontSize: 11, color: Colors.grey),
                ),
                SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 14, color: Color(0xFFF7931A)),
              ],
            ),
          ),
        ],
      );
    case TrailingType.typeRegistered:
      return IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.chevron_right),
        color: const Color(0xFFF7931A),
        iconSize: 20,
      );
  }
}

class EventTile extends StatelessWidget {
  final String imagelocation, title, subtitle;
  final String timeText;
  final VoidCallback? onTap;
  final TrailingType type;

  const EventTile({
    super.key,
    required this.imagelocation,
    required this.title,
    required this.subtitle,
    this.timeText = "5:30 PM",
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: 0.9 * maxWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF7F7FA),
            radius: 24,
            backgroundImage: imagelocation.startsWith('http')
                ? NetworkImage(imagelocation) as ImageProvider
                : AssetImage(imagelocation),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9395A4), fontSize: 12),
          ),
          trailing: buildTrailing(type, onTap, timeText: timeText),
        ),
      ),
    );
  }
}

class XploreTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;

  const XploreTile({
    super.key,
    this.onTap,
    this.title = "Xplore More",
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: width * 0.1),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 0.03),
            child: IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right),
              color: const Color(0xFFF7931A),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
