import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_event_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class UserUpcomingEventsScreen extends StatelessWidget {
  final Function(int) changeindex;
  const UserUpcomingEventsScreen({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.scaffoldBackground,
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
                Align(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 16, left: 24),
                    child: Text(
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
                      right: width * 0.02),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: AppColors.scaffoldBackground,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.02,
                      left: width * 0.03,
                      right: width * 0.03,
                    ),
                    child: BlocBuilder<EventBloc, EventState>(
                      builder: (context, state) {
                        if (state is EventLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is EventError) {
                          return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
                        } else if (state is EventsLoaded) {
                          final upcoming = state.upcomingEvents;
                          if (upcoming.isEmpty) {
                            return const Center(
                              child: Text(
                                "No upcoming events yet.",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<EventBloc>().add(FetchAllEvents());
                            },
                            child: ListView.builder(
                              itemCount: upcoming.length,
                              padding: const EdgeInsets.only(bottom: 120),
                              itemBuilder: (BuildContext context, int index) {
                                final event = upcoming[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: EventTile(
                                    imagelocation: event.imageLocation ?? 'assets/octave.png',
                                    title: event.title,
                                    subtitle: event.subtitle ?? '',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserEventDetailsScreen(
                                            event: event,
                                            changeindex: changeindex,
                                            preview: EventDraft.no,
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
          );
        },
      ),
    );
  }
}