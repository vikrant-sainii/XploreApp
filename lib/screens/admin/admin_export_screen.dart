import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';

class AdminExportScreen extends StatefulWidget {
  const AdminExportScreen({super.key});

  @override
  State<AdminExportScreen> createState() => _AdminExportScreenState();
}

class _AdminExportScreenState extends State<AdminExportScreen> {
  String selectedMonth = "all";
  String selectedYear = "2026";

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchExportDataRequested(month: selectedMonth, year: selectedYear));
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
          "Event Analytics & Export",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF191C32),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedMonth,
                    dropdownColor: const Color(0xFF191C32),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Month Filter",
                      labelStyle: const TextStyle(color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      filled: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All Months")),
                      DropdownMenuItem(value: "1", child: Text("January")),
                      DropdownMenuItem(value: "2", child: Text("February")),
                      DropdownMenuItem(value: "3", child: Text("March")),
                      DropdownMenuItem(value: "4", child: Text("April")),
                      DropdownMenuItem(value: "5", child: Text("May")),
                      DropdownMenuItem(value: "8", child: Text("August")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedMonth = val);
                        context.read<AdminBloc>().add(FetchExportDataRequested(month: selectedMonth, year: selectedYear));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedYear,
                    dropdownColor: const Color(0xFF191C32),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Year Filter",
                      labelStyle: const TextStyle(color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      filled: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: "2026", child: Text("2026")),
                      DropdownMenuItem(value: "2025", child: Text("2025")),
                      DropdownMenuItem(value: "2024", child: Text("2024")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedYear = val);
                        context.read<AdminBloc>().add(FetchExportDataRequested(month: selectedMonth, year: selectedYear));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Events Report List
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> events = [];
                if (state is AdminExportLoaded) {
                  events = state.events;
                }

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.analytics_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No exported event data for selected filters", style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final ev = events[index];
                    final eventName = ev['eventName']?.toString() ?? 'Event';
                    final clubName = ev['clubName']?.toString() ?? 'Club';
                    final totalRegistrations = ev['totalRegistrations'] ?? 0;
                    final totalAmountReceived = ev['totalAmountReceived'] ?? 0;
                    final eventType = ev['eventType']?.toString() ?? 'Free';

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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: eventType.toUpperCase() == 'PAID' ? const Color(0xFFFFEBE4) : const Color(0xFFDEF5E9),
                            child: Icon(
                              eventType.toUpperCase() == 'PAID' ? Icons.monetization_on : Icons.card_giftcard,
                              color: eventType.toUpperCase() == 'PAID' ? const Color(0xFFF7931A) : const Color(0xFF5FC88F),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191C32))),
                                const SizedBox(height: 2),
                                Text("Club: $clubName", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("$totalRegistrations Registrations", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191C32))),
                              Text("₹$totalAmountReceived Collected", style: const TextStyle(color: Color(0xFF5FC88F), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
