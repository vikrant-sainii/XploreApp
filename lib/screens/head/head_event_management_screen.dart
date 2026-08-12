import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class HeadEventManagementScreen extends StatelessWidget {
  final Function(int) changeindex;
  const HeadEventManagementScreen({super.key, required this.changeindex});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "6.00 pm";
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final ampm = dateTime.hour >= 12 ? "pm" : "am";
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour.$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            iconSize: 24,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardColor,
              shape: const CircleBorder(),
            ),
            onPressed: () {
              changeindex(0);
            },
          ),
        ),
        actions: [
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardColor,
              shape: const CircleBorder(),
            ),
            color: Colors.white,
          ),
          const SizedBox(width: 12)
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Container(
            color: AppColors.scaffoldBackground,
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16, left: 24),
                    child: Text(
                      "Event\nManagement",
                      style: TextStyle(
                        color: Colors.white,
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
                      right: width * 0.02),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: AppColors.cardColor,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: ListView(
                      children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "ADD EVENT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
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
                                    icon: const Icon(Icons.add,
                                        color: Colors.black),
                                    onPressed: () => changeindex(1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(35),
                                border: Border.all(
                                    color: AppColors.border, width: 1),
                              ),
                              child: BlocBuilder<HeadBloc, HeadState>(
                                builder: (context, state) {
                                  final stats = state is HeadDashboardLoaded
                                      ? state.stats
                                      : {};
                                  final totalEvents = stats['totalEvents'] ??
                                      stats['eventCount'] ??
                                      0;
                                  final completedEvents =
                                      stats['completedEvents'] ?? 0;
                                  final upcomingEvents =
                                      stats['upcomingEvents'] ?? 0;
                                  final totalParticipants =
                                      stats['totalParticipants'] ??
                                          stats['participantCount'] ??
                                          0;

                                  return GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 1.3,
                                    children: [
                                      _statCard(
                                          "$totalEvents", "TOTAL\nEVENTS"),
                                      _statCard("$completedEvents",
                                          "COMPLETED\nEVENTS"),
                                      _statCard("$upcomingEvents",
                                          "UPCOMING\nEVENTS"),
                                      _statCard("$totalParticipants",
                                          "PARTICIPANTS\nJOINED"),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 35),
                            const Text(
                              "EVENTS LIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<EventBloc, EventState>(
                              builder: (context, state) {
                                if (state is EventLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (state is EventsLoaded) {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  String? myClubId;
                                  if (authState is Authenticated) {
                                    myClubId = authState.user.clubId;
                                    if (myClubId == null && authState.user.memberships.isNotEmpty) {
                                      try {
                                        myClubId = authState.user.memberships.firstWhere(
                                          (m) => m.role.toUpperCase() == "HEAD",
                                          orElse: () => authState.user.memberships.first,
                                        ).clubId;
                                      } catch (_) {}
                                    }
                                  }

                                  final allEvents = [
                                    ...state.registeredEvents,
                                    ...state.upcomingEvents
                                  ];
                                  final filteredEvents = allEvents
                                      .where((e) => e.clubId == myClubId)
                                      .toList();
                                  if (filteredEvents.isEmpty) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Text(
                                        "No events created by your club yet.",
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 15),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: filteredEvents.map((event) {
                                       final status = (event.startTime != null && event.startTime!.isBefore(DateTime.now())) ? "COMPLETED" : "UPCOMING";
                                       final dateStr = event.startTime != null
                                           ? "${event.startTime!.day}/${event.startTime!.month} , ${_formatDateTime(event.startTime)}\nVENUE-${event.venue ?? 'WE2'}"
                                           : "No date set\nVENUE-${event.venue ?? 'WE2'}";
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: _eventListItem(
                                            event.title, dateStr, status),
                                      );
                                    }).toList(),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 100),
                          ],
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
}

Widget _statCard(String value, String label) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.cardColor,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

Widget _eventListItem(String title, String details, String status) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.scaffoldBackground,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              status == "COMPLETED" ? Icons.check_circle : Icons.schedule,
              color: status == "COMPLETED" ? Colors.green : AppColors.primary,
              size: 28,
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
