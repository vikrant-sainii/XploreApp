import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/models/event_model.dart';
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
  String _selectedFilter = 'All'; // 'All', 'Upcoming', 'Registered'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventBloc>().add(const FetchAllEvents());
    });
  }

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
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  widget.changeindex(0);
                }
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
                      "College\nEvents",
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
                          onChanged: (_) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: "Search events, venue, clubs...",
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
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
                      const SizedBox(height: 10),

                      // Filter chips (All Events, Upcoming, Registered)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                        child: Row(
                          children: [
                            _buildFilterChip("All Events", "All"),
                            const SizedBox(width: 8),
                            _buildFilterChip("Upcoming", "Upcoming"),
                            const SizedBox(width: 8),
                            _buildFilterChip("Registered", "Registered"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: BlocBuilder<EventBloc, EventState>(
                            builder: (context, state) {
                              if (state is EventLoading) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (state is EventsLoaded) {
                                // Retrieve all events
                                List<EventModel> baseEvents;
                                if (_selectedFilter == 'Registered') {
                                  baseEvents = state.registeredEvents;
                                } else if (_selectedFilter == 'Upcoming') {
                                  baseEvents = state.upcomingEvents;
                                } else {
                                  // Every event of the college
                                  baseEvents = state.allEvents.isNotEmpty
                                      ? state.allEvents
                                      : (state.upcomingEvents.isNotEmpty
                                          ? state.upcomingEvents
                                          : state.registeredEvents);
                                }

                                // Apply search filter
                                final query = _searchController.text.trim().toLowerCase();
                                List<EventModel> events = query.isEmpty
                                    ? List<EventModel>.from(baseEvents)
                                    : baseEvents.where((e) {
                                        final title = e.title.toLowerCase();
                                        final venue = (e.venue ?? '').toLowerCase();
                                        final club = e.clubName.toLowerCase();
                                        return title.contains(query) ||
                                            venue.contains(query) ||
                                            club.contains(query);
                                      }).toList();

                                // ALWAYS SORT EVERY EVENT BY TIME
                                events.sort((a, b) {
                                  if (a.startTime == null && b.startTime == null) return 0;
                                  if (a.startTime == null) return 1;
                                  if (b.startTime == null) return -1;
                                  return a.startTime!.compareTo(b.startTime!);
                                });

                                if (events.isEmpty) {
                                  return Center(
                                    child: Text(
                                      query.isNotEmpty
                                          ? "No matching events found."
                                          : "No events found.",
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  );
                                }

                                return RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<EventBloc>().add(const FetchAllEvents());
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 90),
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
                                          subtitle: "${event.formattedDate} • ${event.subtitle}",
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
                                          type: event.isRegistered
                                              ? TrailingType.typeRegistered
                                              : TrailingType.typeUpcoming,
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF191C32),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFF191C32),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF191C32) : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
    );
  }
}