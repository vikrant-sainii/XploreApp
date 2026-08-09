import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/screens/user/user_clubs_screen.dart';
import 'package:xplore_app/screens/user/user_event_details_screen.dart';
import 'package:xplore_app/config/theme.dart';

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
                      child: Text(
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
                        Text(
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
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is EventError) {
                            return Center(child: Text(state.message));
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
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is EventError) {
                            return Center(child: Text(state.message));
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

//functions for optimisation
enum TrailingType { typeUpcoming, typeRegistered }

Widget buildTrailing(TrailingType type, VoidCallback? onTap) {
  switch (type) {
    case (TrailingType.typeUpcoming):
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("5:30 PM",
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.angleRight,
                  size: 14, color: AppColors.primary),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "See More Info",
                  style: TextStyle(
                      letterSpacing: -1,
                      fontSize: 12,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      );
    case (TrailingType.typeRegistered):
      return IconButton(
        onPressed: onTap,
        icon: Icon(FontAwesomeIcons.angleRight),
        color: AppColors.primary,
      );
  }
}

//Event Tile-registerd/upcoming
class EventTile extends StatelessWidget {
  final String imagelocation, title, subtitle;
  final VoidCallback? onTap;
  final TrailingType type;

  const EventTile({
    super.key,
    required this.imagelocation,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height;
    final maxWidth = MediaQuery.sizeOf(context).width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: 0.9 * maxWidth,
      height: 0.1 * maxHeight,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: imagelocation.startsWith('http://') ||
                      imagelocation.startsWith('https://')
                  ? Image.network(
                      imagelocation,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    )
                  : Image.asset(
                      imagelocation,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            buildTrailing(type, onTap),
          ],
        ),
      ),
    );
  }
}

//XploreMore Events Tile
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
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      height: height * 0.04,
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: width * 0.1),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 0.05),
            child: IconButton(
              onPressed: onTap,
              icon: Icon(FontAwesomeIcons.angleRight),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget customAppBar(double width, BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(40), // app bar height
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 32,
              color: Colors.white,
            ),
            SizedBox(width: width * 0.04),
            const Text(
              "Welcome Home",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(), // pushes logout button to right
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.apps, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserClubsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
