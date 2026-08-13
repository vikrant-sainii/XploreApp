import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xplore_app/blocs/participation/participation_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class HeadCheckinScreen extends StatefulWidget {
  final String? eventId;
  const HeadCheckinScreen({super.key, this.eventId});

  @override
  State<HeadCheckinScreen> createState() => _HeadCheckinScreenState();
}

class _HeadCheckinScreenState extends State<HeadCheckinScreen> {
  final TextEditingController _qrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      context.read<ParticipationBloc>().add(FetchEventRegistrations(widget.eventId!));
    }
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    final code = _qrController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter QR code data or ticket ID.")),
      );
      return;
    }

    context.read<ParticipationBloc>().add(VerifyQRAttendance(code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "EVENT CHECK-IN & QR ATTENDANCE",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<ParticipationBloc, ParticipationState>(
        listener: (context, state) {
          if (state is QRAttendanceSuccess) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.cardColor,
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 10),
                    Text("Attendance Verified!", style: TextStyle(color: Colors.white)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Participant: ${state.participantName}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    if (state.rollNo != null) Text("Roll No: ${state.rollNo}", style: const TextStyle(color: AppColors.textSecondary)),
                    if (state.externalEmail != null) Text("Email: ${state.externalEmail}", style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text("Attended at: ${state.attendedAt ?? 'Now'}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _qrController.clear();
                      if (widget.eventId != null) {
                        context.read<ParticipationBloc>().add(FetchEventRegistrations(widget.eventId!));
                      }
                    },
                    child: const Text("NEXT STUDENT", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          } else if (state is ParticipationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Manual verification card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(FontAwesomeIcons.qrcode, color: AppColors.primary, size: 24),
                      SizedBox(width: 12),
                      Text("Scan / Enter Ticket Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _qrController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter QR payload / Roll Number...",
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<ParticipationBloc, ParticipationState>(
                    builder: (context, state) {
                      final isLoading = state is ParticipationLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                            : const Text("VERIFY ATTENDANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "PARTICIPANTS REGISTERED",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),

            // Registered list
            BlocBuilder<ParticipationBloc, ParticipationState>(
              builder: (context, state) {
                if (state is EventRegistrationsLoaded) {
                  final list = state.registrations;
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No participant registrations found.", style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return Column(
                    children: list.map((reg) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reg.student?.name ?? reg.externalName ?? "Participant",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  reg.student?.rollNo ?? reg.externalEmail ?? "",
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: reg.isAttended ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                reg.isAttended ? "ATTENDED" : "REGISTERED",
                                style: TextStyle(
                                  color: reg.isAttended ? Colors.greenAccent : Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
