import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'user_home_screen.dart';
import 'user_event_details_screen.dart';

class UserUpcomingEventsScreen extends StatefulWidget {
  final Function(int) changeindex;
  const UserUpcomingEventsScreen({super.key, required this.changeindex});

  @override
  State<UserUpcomingEventsScreen> createState() => _UserUpcomingEventsScreenState();
}

class _UserUpcomingEventsScreenState extends State<UserUpcomingEventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: const Color(0xFFFF9AB2),
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
              onPressed: () {
                widget.changeindex(0);
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Container(
            color: const Color(0xFFFF9AB2),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 24),
                    child: const Text(
                      "Upcoming\nEvents",
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
                    right: width * 0.02,
                  ),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color(0xFFF7F7FA),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Search bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<EventBloc>().add(SearchEvents(val));
                          },
                          decoration: InputDecoration(
                            hintText: "Search events, venue, clubs...",
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: BlocBuilder<EventBloc, EventState>(
                            builder: (context, state) {
                              if (state is EventLoading) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (state is EventsLoaded) {
                                final events = state.filteredEvents.isNotEmpty
                                    ? state.filteredEvents
                                    : state.upcomingEvents;

                                if (events.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "No upcoming events found.",
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  );
                                }

                                return RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<EventBloc>().add(const FetchAllEvents());
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: events.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final event = events[index];
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: EventTile(
                                          imagelocation: event.imageLocation,
                                          title: event.title,
                                          subtitle: event.subtitle,
                                          timeText: event.formattedTime,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => UserEventDetailsScreen(
                                                  changeindex: widget.changeindex,
                                                  preview: EventDraft.no,
                                                  event: event,
                                                ),
                                              ),
                                            );
                                          },
                                          type: TrailingType.typeUpcoming,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ],
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