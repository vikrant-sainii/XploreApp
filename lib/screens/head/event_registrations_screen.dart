import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/participation_model.dart';
import '../../services/event_service.dart';
import 'head_attendance_screen.dart';

class EventRegistrationsScreen extends StatefulWidget {
  final EventModel event;

  const EventRegistrationsScreen({super.key, required this.event});

  @override
  State<EventRegistrationsScreen> createState() => _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _searchController = TextEditingController();

  List<ParticipationModel> _allRegistrations = [];
  List<ParticipationModel> _filteredRegistrations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrations() async {
    setState(() => _isLoading = true);
    try {
      final list = await _eventService.getEventRegistrations(widget.event.id);
      if (mounted) {
        setState(() {
          _allRegistrations = list;
          _filteredRegistrations = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      setState(() => _filteredRegistrations = _allRegistrations);
    } else {
      setState(() {
        _filteredRegistrations = _allRegistrations.where((p) {
          final name = p.participantName.toLowerCase();
          final roll = p.participantRollNo?.toLowerCase() ?? '';
          final email = p.participantEmail.toLowerCase();
          return name.contains(q) || roll.contains(q) || email.contains(q);
        }).toList();
      });
    }
  }

  Future<void> _toggleManualAttendance(ParticipationModel p) async {
    try {
      await _eventService.checkInManual(widget.event.id, p.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${p.participantName} marked as attended!"), backgroundColor: Colors.green),
      );
      _loadRegistrations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _allRegistrations.length;
    final attended = _allRegistrations.where((p) => p.isAttended).length;

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
        title: Text(
          widget.event.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HeadAttendanceScreen(
                    eventId: widget.event.id,
                    eventTitle: widget.event.title,
                  ),
                ),
              ).then((_) => _loadRegistrations());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF191C32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountBox("Total Registered", total.toString(), const Color(0xFFF8B6D1)),
                    _buildCountBox("Attended", attended.toString(), const Color(0xFF5FC88F)),
                    _buildCountBox("Pending", (total - attended).toString(), const Color(0xFFF7931A)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search name, roll no, email...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRegistrations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.how_to_reg, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text("No participants registered yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRegistrations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRegistrations.length,
                          itemBuilder: (context, index) {
                            final p = _filteredRegistrations[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: p.isAttended ? const Color(0xFFDEF5E9) : const Color(0xFFF7F7FA),
                                    child: Icon(
                                      p.isAttended ? Icons.check : Icons.person,
                                      color: p.isAttended ? const Color(0xFF5FC88F) : Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.participantName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        if (p.participantRollNo != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            "Roll: ${p.participantRollNo}",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                        Text(
                                          p.participantEmail,
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: p.isAttended ? null : () => _toggleManualAttendance(p),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: p.isAttended ? Colors.grey.shade200 : const Color(0xFF191C32),
                                      foregroundColor: p.isAttended ? Colors.green : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    child: Text(
                                      p.isAttended ? "ATTENDED" : "CHECK IN",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: p.isAttended ? Colors.green : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
