import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/models/event_model.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/services/event_service.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';

enum EventDraft { yes, no } //function optimisation

class UserEventDetailsScreen extends StatelessWidget {
  final EventModel? event;
  final Function(int) changeindex;
  final EventDraft preview;
  const UserEventDetailsScreen({
    super.key,
    this.event,
    required this.changeindex,
    required this.preview,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "5.30 pm";
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final ampm = dateTime.hour >= 12 ? "pm" : "am";
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour.$minute $ampm";
  }

  void _handleRegistrationAction(BuildContext context, UserModel? user) async {
    if (event == null) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to register for events.")),
      );
      return;
    }

    final eventService = EventService();
    final isRegistered = event!.isRegistered;

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Map<String, dynamic> result;
    if (isRegistered) {
      result = await eventService.deregisterFromEvent(event!.id, user.id);
    } else {
      result = await eventService.registerForEvent(event!.id);
    }

    if (context.mounted) {
      // Dismiss loading dialog
      Navigator.pop(context);
    }

    if (result['success'] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                (isRegistered
                    ? "Deregistered successfully!"
                    : "Registered successfully!")),
            backgroundColor: Colors.green,
          ),
        );
        // Trigger event list refresh
        context.read<EventBloc>().add(FetchAllEvents());
        // Go back
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Action failed."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    final title = event?.title ?? "Bhangra Workshop";
    final venue = event?.venue ?? "A3, Civil Building";
    final description = event?.description ?? "Lorem ipsum dolor sit amet...";
    final timeStr = _formatDateTime(event?.startTime);

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
              Navigator.pop(context);
            },
          ),
        ),
        title: preview == EventDraft.yes
            ? const Text(
                "EVENT PREVIEW",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              )
            : null,
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 24),
                    child: SizedBox(
                      width: width * 0.45,
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: -1,
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          height: 1.1,
                        ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 23,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                  fontSize: 17,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Venue : $venue',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Description",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 23,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Previous Event Highlight",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 23,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.scaffoldBackground,
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/dogworkshop.png",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.scaffoldBackground,
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/dogworkshop.png",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "OUR EVENT",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 23,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: (() {
                            final imgPath = event?.imageLocation ?? event?.imageUrl ?? "assets/workshopevent.png";
                            if (imgPath.startsWith('http://') || imgPath.startsWith('https://')) {
                              return Image.network(
                                imgPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                              );
                            }
                            return Image.asset(
                              imgPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                            );
                          }()),
                        ),
                        if (preview == EventDraft.no) ...[
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _handleRegistrationAction(
                                context, currentUser),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: event?.isRegistered == true
                                  ? Colors.red
                                  : AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              event?.isRegistered == true
                                  ? "DEREGISTER FROM EVENT"
                                  : "REGISTER FOR EVENT",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 80),
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
