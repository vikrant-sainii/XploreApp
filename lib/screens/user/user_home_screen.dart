import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/screens/user/user_event_details_screen.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/components/event_tile.dart';
import 'package:xplore_app/components/custom_app_bar.dart';

class UserHomeScreen extends StatelessWidget {
  final Function(int) changeindex;
  const UserHomeScreen({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(MediaQuery.of(context).size.width, context),
      backgroundColor: AppColors.scaffoldBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return ListView(
            children: [
              SizedBox(
                height: height * 0.05,
              ),
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Image.asset(
                      "assets/welcframe.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.015,
                    left: width * 0.1,
                    child: TextButton(
                      onPressed: () {
                        changeindex(2);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        "Tap to Xplore",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.05,
              ),
              //general container(is used in screen 2 and screen 3)
              Container(
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppColors.scaffoldBackground),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.05,
                        ),
                        const Text(
                          "Registered Events",
                          style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.w500,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                      ),
                      child: BlocBuilder<EventBloc, EventState>(
                        buildWhen: (previous, current) =>
                            current is EventsLoaded ||
                            (current is EventInitial) ||
                            (current is EventLoading && previous is! EventsLoaded) ||
                            (current is EventError && previous is! EventsLoaded),
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is EventError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(state.message, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => context.read<EventBloc>().add(FetchAllEvents()),
                                    icon: const Icon(Icons.refresh, color: AppColors.primary, size: 16),
                                    label: const Text("Retry", style: TextStyle(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is EventsLoaded) {
                            if (state.registeredEvents.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text("No registered events found.", style: TextStyle(color: Colors.white70)),
                              );
                            }
                            return Column(
                              children: state.registeredEvents.map((event) {
                                return EventTile(
                                  imagelocation: event.imageLocation ??
                                      'assets/octave.png',
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
                                  type: TrailingType.typeRegistered,
                                );
                              }).toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    XploreTile(
                      onTap: () {
                        changeindex(1);
                      },
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.05,
                        ),
                        const Text(
                          "Upcoming Events",
                          style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.w500,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                      ),
                      child: BlocBuilder<EventBloc, EventState>(
                        buildWhen: (previous, current) =>
                            current is EventsLoaded ||
                            (current is EventInitial) ||
                            (current is EventLoading && previous is! EventsLoaded) ||
                            (current is EventError && previous is! EventsLoaded),
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is EventError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(state.message, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => context.read<EventBloc>().add(FetchAllEvents()),
                                    icon: const Icon(Icons.refresh, color: AppColors.primary, size: 16),
                                    label: const Text("Retry", style: TextStyle(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is EventsLoaded) {
                            if (state.upcomingEvents.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text("No upcoming events found.", style: TextStyle(color: Colors.white70)),
                              );
                            }
                            return Column(
                              children: state.upcomingEvents.map((event) {
                                return EventTile(
                                  imagelocation: event.imageLocation ??
                                      'assets/octave.png',
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
                                );
                              }).toList(),
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
}


