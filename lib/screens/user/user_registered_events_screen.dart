import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/models/event_model.dart';
import 'package:xplore_app/models/participation_model.dart';
import 'package:xplore_app/services/certificate_service.dart';
import 'user_event_details_screen.dart';

class UserRegisteredEventsScreen extends StatelessWidget {
  final Function(int) changeindex;
  const UserRegisteredEventsScreen({super.key, required this.changeindex});

  void _showTicketDialog(BuildContext context, EventModel event, ParticipationModel? participation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ENTRY PASS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey, letterSpacing: 1.2),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: participation?.isAttended == true ? const Color(0xFFDEF5E9) : const Color(0xFFFFEBE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    participation?.isAttended == true ? "ATTENDED" : "REGISTERED",
                    style: TextStyle(
                      color: participation?.isAttended == true ? const Color(0xFF5FC88F) : const Color(0xFFF7931A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF191C32)),
            ),
            const SizedBox(height: 4),
            Text(
              event.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 140, color: Color(0xFF191C32)),
                  const SizedBox(height: 8),
                  Text(
                    participation?.qrCode.isNotEmpty == true
                        ? participation!.qrCode
                        : "QR-NITJ-${event.id.substring(0, event.id.length > 8 ? 8 : event.id.length)}",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (participation?.isAttended == true)
              ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final certService = CertificateService();
                    await certService.downloadCertificate(event.id);
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Certificate downloaded successfully!"), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text("Certificate status: $e")),
                    );
                  }
                },
                icon: const Icon(Icons.file_download, color: Colors.white, size: 18),
                label: const Text("Download Certificate", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String? currentUserId;
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

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
                changeindex(0);
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
                      "Registered\nEvents",
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
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: BlocBuilder<EventBloc, EventState>(
                            builder: (context, state) {
                              if (state is EventLoading) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (state is EventsLoaded) {
                                final registered = state.registeredEvents;
                                final participations = state.userParticipations;

                                if (registered.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "No Registered Events",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(0, 0, 0, 0.65),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () => changeindex(2),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF191C32),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          ),
                                          child: const Text(
                                            "Explore Upcoming Events",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<EventBloc>().add(FetchAllEvents(userId: currentUserId));
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: registered.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final event = registered[index];
                                      final p = participations.cast<ParticipationModel?>().firstWhere(
                                            (item) => item?.event?.id == event.id || item?.eventId == event.id,
                                            orElse: () => null,
                                          );

                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(25),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => UserEventDetailsScreen(
                                                    changeindex: changeindex,
                                                    preview: EventDraft.no,
                                                    event: event,
                                                  ),
                                                ),
                                              );
                                            },
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            leading: CircleAvatar(
                                              backgroundColor: const Color(0xFFF7F7FA),
                                              radius: 24,
                                              backgroundImage: (event.imageUrl != null && event.imageUrl!.startsWith('http'))
                                                  ? NetworkImage(event.imageUrl!) as ImageProvider
                                                  : (event.imageLocation.startsWith('http')
                                                      ? NetworkImage(event.imageLocation) as ImageProvider
                                                      : AssetImage(event.imageLocation)),
                                            ),
                                            title: Text(
                                              event.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            subtitle: Text(
                                              event.subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Color(0xFF9395A4), fontSize: 12),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () => _showTicketDialog(context, event, p),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF191C32),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  child: const Text("VIEW TICKET", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                ),
                                                const SizedBox(width: 4),
                                                IconButton(
                                                  icon: const Icon(Icons.chevron_right, color: Color(0xFFF7931A), size: 20),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => UserEventDetailsScreen(
                                                          changeindex: changeindex,
                                                          preview: EventDraft.no,
                                                          event: event,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
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
