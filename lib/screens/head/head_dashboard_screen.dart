import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/blocs/notification/notification_bloc.dart';
import 'package:xplore_app/models/event_model.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/notifications_screen.dart';
import 'head_member_management_screen.dart';
import 'head_announcements_screen.dart';
import 'head_attendance_screen.dart';
import 'head_event_management_screen.dart';
import 'head_add_event_screen.dart';
import '../user/user_event_details_screen.dart';

class HeadDashboardScreen extends StatefulWidget {
  final String? clubId;
  final String? clubName;
  final Function(int)? changeindex;

  const HeadDashboardScreen({
    super.key,
    this.clubId,
    this.clubName,
    this.changeindex,
  });

  @override
  State<HeadDashboardScreen> createState() => _HeadDashboardScreenState();
}

class _HeadDashboardScreenState extends State<HeadDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _fetchStats();
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  void _fetchStats() {
    final authState = context.read<AuthBloc>().state;
    String? targetId = widget.clubId;
    if (targetId == null && authState is Authenticated) {
      if (authState.user.clubId != null && authState.user.clubId!.isNotEmpty) {
        targetId = authState.user.clubId;
      } else if (authState.user.memberships.isNotEmpty) {
        final headMem = authState.user.memberships.firstWhere(
          (m) => m.role == 'CLUB_HEAD' || m.role == 'COORDINATOR',
          orElse: () => authState.user.memberships.first,
        );
        targetId = headMem.clubId;
      }
    }
    context.read<HeadBloc>().add(FetchDashboardStats(clubId: targetId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String leadName = "CLUB EXECUTIVE";
    String leadRoll = "OFFICIAL ACCOUNT";
    String clubName = widget.clubName ?? "CLUB DASHBOARD";
    String? clubId = widget.clubId;

    if (authState is Authenticated) {
      leadName = authState.user.name;
      leadRoll = authState.user.rollNo ?? (authState.user.isClubAccount ? "OFFICIAL ACCOUNT" : "STUDENT LEAD");
      if (clubId == null) {
        clubId = authState.user.clubId;
        clubName = authState.user.name;
        if (authState.user.memberships.isNotEmpty) {
          final headMem = authState.user.memberships.firstWhere(
            (m) => m.role == 'CLUB_HEAD' || m.role == 'COORDINATOR',
            orElse: () => authState.user.memberships.first,
          );
          clubName = headMem.clubName ?? authState.user.name;
          clubId = headMem.clubId;
        }
      } else if (widget.clubName == null) {
        if (authState.user.memberships.isNotEmpty) {
          final match = authState.user.memberships.firstWhere(
            (m) => m.clubId == widget.clubId,
            orElse: () => authState.user.memberships.first,
          );
          clubName = match.clubName ?? authState.user.name;
        } else {
          clubName = authState.user.name;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: _buildAppBar(context, clubName),
      body: BlocBuilder<HeadBloc, HeadState>(
        builder: (context, state) {
          Map<String, dynamic> stats = {
            'totalMembers': 120,
            'upcomingEvents': 2,
            'totalEvents': 20,
            'completedEvents': 18,
            'totalParticipants': 200,
          };
          List<EventModel> events = [];

          if (state is HeadDashboardLoaded) {
            stats = state.stats;
            events = state.events;
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchStats();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeadCard(context, leadName, leadRoll, clubName, clubId),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "DASHBOARD",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Color(0xFF191C32),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Members: ${stats['totalMembers']}",
                          style: const TextStyle(color: Color(0xFF5FC88F), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state is HeadLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildDashboardGrid(context, clubId, clubName),
                  const SizedBox(height: 28),
                  _buildRecentActivities(events, clubId, clubName),
                  const SizedBox(height: 120), // Bottom nav padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String clubName) {
    final bool showBack = Navigator.canPop(context) && widget.changeindex == null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
              tooltip: "Back to Student Portal",
            )
          : null,
      title: Row(
        children: [
          Image.asset("assets/gdgc.png", height: 36),
          const SizedBox(width: 8),
          Text(
            "$clubName Portal",
            style: const TextStyle(
              color: Color(0xFF1D1B20),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
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
                  tooltip: "Notifications",
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
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          tooltip: "Logout",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLeadCard(BuildContext context, String leadName, String leadRoll, String clubName, String? clubId) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D27),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$clubName LEAD",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leadName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Roll: $leadRoll",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HeadMemberManagementScreen(
                          clubId: clubId ?? '1',
                          clubName: clubName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                  child: const Text(
                    "Member Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Image.asset(
                "assets/pose.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, String? clubId, String clubName) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: [
        _buildActionCard(
          "Event\nManagement",
          Icons.event_note,
          const Color(0xFF1D1D27),
          Colors.white,
          () {
            if (widget.changeindex != null) {
              widget.changeindex!(2);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HeadEventManagementScreen(
                    clubId: clubId,
                    clubName: clubName,
                  ),
                ),
              );
            }
          },
        ),
        _buildActionCard(
          "Member\nManagement",
          Icons.groups,
          const Color(0xFFF8B6D1),
          const Color(0xFF1D1B20),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HeadMemberManagementScreen(
                  clubId: clubId ?? '1',
                  clubName: clubName,
                ),
              ),
            );
          },
        ),
        _buildActionCard(
          "Make\nAnnouncements",
          Icons.campaign,
          const Color(0xFFF8B6D1),
          const Color(0xFF1D1B20),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HeadAnnouncementsScreen(clubId: clubId),
              ),
            );
          },
        ),
        _buildActionCard(
          "QR Attendance\nCheck-In",
          Icons.qr_code_scanner,
          const Color(0xFF1D1D27),
          Colors.white,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HeadAttendanceScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color bg, Color text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: text, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(List<EventModel> events, String? clubId, String clubName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECENT ACTIVITIES",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Color(0xFF1D1B20),
          ),
        ),
        const SizedBox(height: 14),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "🦗 *Cricket noises...*",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B20),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "No active events right now! Time to wake up the campus and launch your next big event! 🚀",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.changeindex != null) {
                      widget.changeindex!(1);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HeadAddEventScreen(
                            clubId: clubId,
                            clubName: clubName,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Create Event"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D1B20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...events.take(3).map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildActivityTile(
                    event: e,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserEventDetailsScreen(
                            changeindex: widget.changeindex ?? (_) {},
                            preview: EventDraft.no,
                            event: e,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildActivityTile({
    required EventModel event,
    required VoidCallback onTap,
  }) {
    final asset = event.imageLocation;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF6F7FA),
                radius: 22,
                backgroundImage: asset.startsWith('http')
                    ? NetworkImage(asset) as ImageProvider
                    : AssetImage(
                        asset.isNotEmpty ? asset : 'assets/gdgc.png',
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      event.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                event.formattedTime,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF7931A),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

