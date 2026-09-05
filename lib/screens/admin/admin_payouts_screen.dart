import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';

class AdminPayoutsScreen extends StatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  State<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends State<AdminPayoutsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const FetchAdminStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF191C32),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: IconButton(
              iconSize: 18,
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Payouts & Financials",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> eventStats = [];
          if (state is AdminDashboardLoaded) {
            eventStats = state.stats['eventStats'] is List ? state.stats['eventStats'] : [];
          }

          if (eventStats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.monetization_on, size: 50, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No event payout records available", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventStats.length,
            itemBuilder: (context, index) {
              final ev = eventStats[index];
              final eventId = ev['eventId']?.toString() ?? '';
              final title = ev['title']?.toString() ?? 'Event';
              final clubName = ev['clubName']?.toString() ?? 'Club';
              final totalCollected = ev['totalCollected'] ?? 0;
              final regCount = ev['regCount'] ?? 0;
              final payoutStatus = ev['payoutStatus']?.toString().toUpperCase() ?? 'PENDING';

              final bool isCompleted = payoutStatus == 'COMPLETED';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFDEF5E9) : const Color(0xFFFFEBE4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCompleted ? "COMPLETED" : "PENDING PAYOUT",
                            style: TextStyle(
                              color: isCompleted ? const Color(0xFF5FC88F) : const Color(0xFFF7931A),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("Club: $clubName", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("TOTAL REVENUE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text("₹$totalCollected", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5FC88F))),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("REGISTRATIONS", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text("$regCount Joins", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191C32))),
                          ],
                        ),
                      ],
                    ),
                    if (!isCompleted && eventId.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AdminBloc>().add(CompletePayoutRequested(eventId));
                          },
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          label: const Text("MARK PAYOUT AS COMPLETED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF191C32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
