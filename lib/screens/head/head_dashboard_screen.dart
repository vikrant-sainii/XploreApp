import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/config/theme.dart';

class HeadDashboardScreen extends StatelessWidget {
  final Function(int) changeindex;
  const HeadDashboardScreen({super.key, required this.changeindex});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "5.30 pm";
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final ampm = dateTime.hour >= 12 ? "pm" : "am";
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour.$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context, currentUser),
      body: BlocBuilder<HeadBloc, HeadState>(
        builder: (context, state) {
          if (state is HeadInitial) {
            context.read<HeadBloc>().add(FetchDashboardStats());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadCard(context, currentUser),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "DASHBOARD",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    if (state is HeadDashboardLoaded)
                      Text("Total Members: ${state.stats['totalMembers'] ?? 0}", 
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold))
                  ],
                ),
                const SizedBox(height: 16),
                if (state is HeadLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildDashboardGrid(context),
                const SizedBox(height: 32),
                _buildRecentActivities(context),
                const SizedBox(height: 100), // Avoid being hidden by bottom nav
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserModel? currentUser) {
    final clubName = currentUser?.role == 'club' && (currentUser?.memberships.isEmpty ?? true)
        ? (currentUser?.name ?? "Club Head")
        : (currentUser?.memberships.isNotEmpty == true
            ? (currentUser!.memberships.firstWhere((m) => m.role.toUpperCase() == "HEAD",
                orElse: () => currentUser.memberships.first).clubName ?? "Head Portal")
            : "Head Portal");

    final logo = currentUser?.role == 'club' && (currentUser?.memberships.isEmpty ?? true)
        ? "assets/gdgc.png"
        : (currentUser?.memberships.isNotEmpty == true
            ? (currentUser!.memberships.firstWhere((m) => m.role.toUpperCase() == "HEAD",
                orElse: () => currentUser.memberships.first).clubLogo ?? "assets/gdgc.png")
            : "assets/gdgc.png");

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        tooltip: "Back to Student View",
      ),
      title: Row(
        children: [
          logo.startsWith('http://') || logo.startsWith('https://')
              ? Image.network(logo, height: 40, errorBuilder: (_, __, ___) => Image.asset("assets/gdgc.png", height: 40))
              : Image.asset(logo, height: 40, errorBuilder: (_, __, ___) => Image.asset("assets/gdgc.png", height: 40)),
          const SizedBox(width: 8),
          Text(
            clubName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          tooltip: "Logout",
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const CircleAvatar(
            backgroundColor: AppColors.cardColor,
            radius: 18,
            child: Icon(Icons.person_outline, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCard(BuildContext context, UserModel? currentUser) {
    final String clubLabel;
    final String leadName;
    final String secondaryInfo;

    if (currentUser?.role == 'club' && (currentUser?.memberships.isEmpty ?? true)) {
      clubLabel = currentUser?.name ?? "Club Coordinator";
      leadName = "Official Account";
      secondaryInfo = currentUser?.email ?? "";
    } else {
      leadName = currentUser?.name ?? "NAME OF LEAD";
      secondaryInfo = currentUser?.rollNo ?? "Roll no of lead";
      clubLabel = currentUser?.memberships.isNotEmpty == true 
          ? (currentUser!.memberships.firstWhere((m) => m.role.toUpperCase() == "HEAD", 
              orElse: () => currentUser.memberships.first).clubName ?? "Club Coordinator") 
          : "Club Coordinator";
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  clubLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leadName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  secondaryInfo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {}, // Clickable but no destination
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    "Member Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          "Event\nManagement",
          FontAwesomeIcons.cube,
          AppColors.cardColor,
          Colors.white,
          onTap: () => changeindex(3),
        ),
        _buildActionCard(
          "Member\nManagement",
          FontAwesomeIcons.masksTheater,
          AppColors.cardColor,
          Colors.white,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Member Management module coming soon.")),
            );
          },
        ),
        _buildActionCard(
          "Make\nAnnouncements",
          FontAwesomeIcons.towerBroadcast,
          AppColors.cardColor,
          Colors.white,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Announcements module coming soon.")),
            );
          },
        ),
        _buildActionCard(
          "Task\nManagement",
          FontAwesomeIcons.creditCard,
          AppColors.cardColor,
          Colors.white,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Task Management module coming soon.")),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color bg, Color text, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECENT ACTIVITIES",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
            } else if (state is EventsLoaded) {
              final allEvents = [...state.registeredEvents, ...state.upcomingEvents];
              if (allEvents.isEmpty) {
                return const Text(
                  "No recent events found.",
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }
              final displayEvents = allEvents.take(3).toList();
              return Column(
                children: displayEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildActivityTile(
                      event.title,
                      event.venue ?? "WE2",
                      _formatDateTime(event.startTime),
                      event.imageLocation ?? "assets/gdgc.png",
                    ),
                  );
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildActivityTile(String title, String venue, String time, String asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.scaffoldBackground,
            radius: 24,
            backgroundImage: asset.startsWith('http://') || asset.startsWith('https://')
                ? NetworkImage(asset)
                : AssetImage(asset) as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                Text(
                  venue,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("See More Info", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  Icon(Icons.keyboard_arrow_up, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
