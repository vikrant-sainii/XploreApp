import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/models/event_model.dart';
import '../user/user_event_details_screen.dart';
import 'event_registrations_screen.dart';

class HeadEventManagementScreen extends StatelessWidget {
  final Function(int) changeindex;
  const HeadEventManagementScreen({super.key, required this.changeindex});

  void _showEventActionsModal(BuildContext context, EventModel event, String? clubId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF191C32)),
            ),
            const SizedBox(height: 4),
            Text("Status: ${event.reviewStatus}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDEF5E9),
                child: Icon(Icons.people, color: Color(0xFF5FC88F)),
              ),
              title: const Text("View Registered Participants", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${event.registeredCount} students registered"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventRegistrationsScreen(event: event)),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBE4),
                child: Icon(Icons.rate_review_outlined, color: Color(0xFFF7931A)),
              ),
              title: const Text("Review / Preview Event", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Inspect full specs & approve/reject proposal"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserEventDetailsScreen(
                      changeindex: changeindex,
                      preview: EventDraft.yes,
                      event: event,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text("Delete Event", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: const Text("Permanently remove this event"),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteEvent(context, event, clubId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteEvent(BuildContext context, EventModel event, String? clubId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Delete Event?"),
        content: Text("Are you sure you want to permanently delete '${event.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HeadBloc>().add(DeleteClubEvent(event.id, clubId: clubId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? clubId;
    if (authState is Authenticated) {
      clubId = authState.user.clubId;
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: const Color(0xFFF7F7FA),
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              iconSize: 24,
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              onPressed: () => changeindex(0),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Container(
            color: const Color(0xFFF7F7FA),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 24),
                    child: const Text(
                      "Event\nManagement",
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w600,
                        fontSize: 37,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    "assets/pillar.png",
                    height: height * 0.25,
                    width: width * 0.5,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: height * 0.2,
                    left: width * 0.02,
                    right: width * 0.02,
                  ),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color(0xFF191C32),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 20),
                    child: BlocBuilder<HeadBloc, HeadState>(
                      builder: (context, state) {
                        Map<String, dynamic> stats = {
                          'totalEvents': 20,
                          'completedEvents': 18,
                          'upcomingEvents': 2,
                          'totalParticipants': 200,
                        };
                        List<EventModel> events = [];

                        if (state is HeadDashboardLoaded) {
                          stats = state.stats;
                          events = state.events;
                        }

                        return ListView(
                          children: [
                            // ADD EVENT Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "ADD EVENT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add, color: Colors.black),
                                    onPressed: () => changeindex(1), // Switch to Add Event screen
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Stats Grid Enclosed in White
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.4,
                                children: [
                                  _statCard(stats['totalEvents']?.toString() ?? "20", "TOTAL\nEVENTS"),
                                  _statCard(stats['completedEvents']?.toString() ?? "18", "COMPLETED\nEVENTS"),
                                  _statCard(stats['upcomingEvents']?.toString() ?? "2", "UPCOMING\nEVENTS"),
                                  _statCard(stats['totalParticipants']?.toString() ?? "200", "PARTICIPANTS\nJOINED"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // EVENTS LIST Section
                            const Text(
                              "EVENTS LIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (events.isEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.rocket_launch_outlined, color: Color(0xFFF7931A), size: 42),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "No event proposals found yet! 🚀",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32)),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      "Time to unleash some creativity and create a blockbuster campus event! 🎉",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => changeindex(1),
                                      icon: const Icon(Icons.add, color: Colors.white),
                                      label: const Text("CREATE EVENT PROPOSAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF191C32),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else
                              ...events.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _eventListItem(context, e, clubId),
                                  )),

                            const SizedBox(height: 120),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191C32),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventListItem(BuildContext context, EventModel event, String? clubId) {
    final isApproved = event.reviewStatus == 'PUBLISHED';
    return GestureDetector(
      onTap: () => _showEventActionsModal(context, event, clubId),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF191C32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${event.formattedDate} • ${event.venue ?? 'Main Campus'}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  "STATUS",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  isApproved ? Icons.check_circle : Icons.pending,
                  color: isApproved ? const Color(0xFF5FC88F) : const Color(0xFFF7931A),
                  size: 22,
                ),
                Text(
                  event.reviewStatus,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isApproved ? const Color(0xFF5FC88F) : const Color(0xFFF7931A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
