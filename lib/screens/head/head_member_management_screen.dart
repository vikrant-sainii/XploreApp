import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/head/head_bloc.dart';
import '../../models/club_model.dart';

class HeadMemberManagementScreen extends StatefulWidget {
  final String clubId;
  final String clubName;

  const HeadMemberManagementScreen({
    super.key,
    required this.clubId,
    this.clubName = "GDGC CLUB",
  });

  @override
  State<HeadMemberManagementScreen> createState() => _HeadMemberManagementScreenState();
}

class _HeadMemberManagementScreenState extends State<HeadMemberManagementScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'MEMBER';

  @override
  void initState() {
    super.initState();
    context.read<HeadBloc>().add(FetchClubMembers(widget.clubId));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
    _emailController.clear();
    _selectedRole = 'MEMBER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text("Add Club Member", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter student's official @nitj.ac.in email address:"),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "student@nitj.ac.in",
                  filled: true,
                  fillColor: const Color(0xFFF7F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: "Assign Role",
                  filled: true,
                  fillColor: const Color(0xFFF7F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: "MEMBER", child: Text("Member")),
                  DropdownMenuItem(value: "COORDINATOR", child: Text("Coordinator")),
                  DropdownMenuItem(value: "CLUB_HEAD", child: Text("Club Head")),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => _selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text.trim();
                if (email.isNotEmpty && email.endsWith('@nitj.ac.in')) {
                  Navigator.pop(ctx);
                  context.read<HeadBloc>().add(AddClubMemberRequested(
                        widget.clubId,
                        email,
                        role: _selectedRole,
                      ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid @nitj.ac.in email")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF191C32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Add Member", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPermissionsDialog(ClubMembershipModel member) {
    bool canAttendance = member.canTakeAttendance;
    bool canEdit = member.canEditEvents;
    String role = member.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text("Edit ${member.student?['name'] ?? 'Member'}", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: ['CLUB_HEAD', 'COORDINATOR', 'MEMBER'].contains(role) ? role : 'MEMBER',
                decoration: InputDecoration(
                  labelText: "Role",
                  filled: true,
                  fillColor: const Color(0xFFF7F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: "MEMBER", child: Text("Member")),
                  DropdownMenuItem(value: "COORDINATOR", child: Text("Coordinator")),
                  DropdownMenuItem(value: "CLUB_HEAD", child: Text("Club Head")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      role = val;
                      if (role != 'MEMBER') {
                        canAttendance = true;
                        canEdit = true;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Take Attendance", style: TextStyle(fontSize: 14)),
                value: canAttendance,
                activeThumbColor: const Color(0xFF5FC88F),
                onChanged: (val) => setDialogState(() => canAttendance = val),
              ),
              SwitchListTile(
                title: const Text("Create / Edit Events", style: TextStyle(fontSize: 14)),
                value: canEdit,
                activeThumbColor: const Color(0xFF5FC88F),
                onChanged: (val) => setDialogState(() => canEdit = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<HeadBloc>().add(RemoveClubMemberRequested(member.id, clubId: widget.clubId));
              },
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<HeadBloc>().add(UpdateMemberPermissionsRequested(
                      member.id,
                      role: role,
                      canTakeAttendance: canAttendance,
                      canEditEvents: canEdit,
                      clubId: widget.clubId,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF191C32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HeadBloc, HeadState>(
      listener: (context, state) {
        if (state is HeadActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
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
          title: Text(
            "${widget.clubName} Members",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white),
              onPressed: _showAddMemberDialog,
              tooltip: "Add Member",
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<HeadBloc, HeadState>(
          builder: (context, state) {
            if (state is HeadLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<ClubMembershipModel> members = [];
            if (state is HeadDashboardLoaded) {
              members = state.members;
            }

            if (members.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text("No members found in this club", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: const Icon(Icons.add),
                      label: const Text("Add First Member"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF191C32)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HeadBloc>().add(FetchClubMembers(widget.clubId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final m = members[index];
                  final name = m.student?['name']?.toString() ?? 'Club Member';
                  final email = m.student?['email']?.toString() ?? '';
                  final rollNo = m.student?['rollNo']?.toString() ?? '';
                  final isHead = m.role == 'CLUB_HEAD';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isHead ? const Color(0xFFFFEBE4) : const Color(0xFFDEF5E9),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'M',
                            style: TextStyle(
                              color: isHead ? const Color(0xFFF7931A) : const Color(0xFF5FC88F),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email.isNotEmpty ? email : rollNo,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isHead ? Colors.orange.shade50 : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.role,
                                      style: TextStyle(
                                        color: isHead ? Colors.orange.shade800 : Colors.blue.shade800,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (m.canTakeAttendance) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.qr_code_scanner, size: 14, color: Colors.green),
                                  ],
                                  if (m.canEditEvents) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit_calendar, size: 14, color: Colors.purple),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune, color: Color(0xFF191C32), size: 20),
                          onPressed: () => _showEditPermissionsDialog(m),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
