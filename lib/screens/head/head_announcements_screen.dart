import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/head/head_bloc.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class HeadAnnouncementsScreen extends StatefulWidget {
  final String? clubId;
  const HeadAnnouncementsScreen({super.key, this.clubId});

  @override
  State<HeadAnnouncementsScreen> createState() => _HeadAnnouncementsScreenState();
}

class _HeadAnnouncementsScreenState extends State<HeadAnnouncementsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _targetType = 'ALL_STUDENTS';
  String? _selectedClubName;
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _sentList = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadSentHistory();
  }

  Future<void> _loadSentHistory() async {
    try {
      final list = await _notificationService.getSentNotifications();
      if (mounted) {
        setState(() {
          _sentList = list;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleBroadcast() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and message are required"), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<HeadBloc>().add(SendAnnouncementRequested(
          title: title,
          message: message,
          targetType: _targetType,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    List<String> availableClubs = [];
    bool isAuthorized = false;

    if (authState is Authenticated) {
      final user = authState.user;
      final execMemberships = user.memberships.where((m) {
        final r = m.role.toUpperCase();
        return r == 'HEAD' || r == 'CLUB_HEAD' || r == 'COORDINATOR' || user.isAdmin;
      }).toList();

      availableClubs = execMemberships
          .map((m) => m.clubName)
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toList();

      isAuthorized = availableClubs.isNotEmpty || user.isAdmin || user.isClubHead || user.isCoordinator;
    }

    if (_selectedClubName == null && availableClubs.isNotEmpty) {
      _selectedClubName = availableClubs.first;
    }

    return BlocListener<HeadBloc, HeadState>(
      listener: (context, state) {
        if (state is HeadActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          _titleController.clear();
          _messageController.clear();
          _loadSentHistory();
        } else if (state is HeadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
            "Broadcast Center",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!isAuthorized)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 40),
                    SizedBox(height: 12),
                    Text(
                      "Access Restricted",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32)),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Posting announcements is reserved for Club Heads & Coordinators. Members have read-only access to club notifications.",
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              // Compose Broadcast Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF191C32),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.podcasts, color: Color(0xFFF8B6D1), size: 22),
                        SizedBox(width: 10),
                        Text(
                          "BROADCAST NOTIFICATION",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Club Selector Dropdown
                    if (availableClubs.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("SELECT CLUB:", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              dropdownColor: const Color(0xFF191C32),
                              value: _selectedClubName,
                              style: const TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold, fontSize: 13),
                              items: availableClubs
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedClubName = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Announcement Title",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Type your announcement or update for students...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text("Target Audience: ", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const Spacer(),
                        DropdownButton<String>(
                          dropdownColor: const Color(0xFF191C32),
                          value: _targetType,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          items: const [
                            DropdownMenuItem(value: "ALL_STUDENTS", child: Text("All Students")),
                            DropdownMenuItem(value: "REGISTERED_STUDENTS", child: Text("Registered Only")),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _targetType = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _handleBroadcast,
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      label: const Text(
                        "POST ANNOUNCEMENT",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7931A),
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // Sent Announcements History
            const Text(
              "SENT ANNOUNCEMENTS LOG",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_sentList.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text("No announcements sent yet.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._sentList.map((n) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Text(n.formattedTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(n.message, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                      ],
                    ),
                  )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
