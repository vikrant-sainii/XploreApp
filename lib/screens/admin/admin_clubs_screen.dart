import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';

class AdminClubsScreen extends StatefulWidget {
  const AdminClubsScreen({super.key});

  @override
  State<AdminClubsScreen> createState() => _AdminClubsScreenState();
}

class _AdminClubsScreenState extends State<AdminClubsScreen> {
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _facultyNameController = TextEditingController();
  final TextEditingController _facultyEmailController = TextEditingController();
  final TextEditingController _clubEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const FetchAdminClubs());
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _facultyNameController.dispose();
    _facultyEmailController.dispose();
    _clubEmailController.dispose();
    super.dispose();
  }

  void _showCreateClubDialog() {
    _clubNameController.clear();
    _facultyNameController.clear();
    _facultyEmailController.clear();
    _clubEmailController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Create New Campus Club", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _clubNameController,
                decoration: const InputDecoration(labelText: "Club Name (e.g. ROBOTICS CLUB)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _facultyNameController,
                decoration: const InputDecoration(labelText: "Faculty Coordinator Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _facultyEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Faculty Email (@nitj.ac.in)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _clubEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Official Club Email"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final cName = _clubNameController.text.trim();
              final fName = _facultyNameController.text.trim();
              final fEmail = _facultyEmailController.text.trim();
              final cEmail = _clubEmailController.text.trim();

              if (cName.isNotEmpty && fName.isNotEmpty && fEmail.isNotEmpty && cEmail.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<AdminBloc>().add(CreateAdminClubRequested(
                      clubName: cName,
                      facultyName: fName,
                      facultyEmail: fEmail,
                      clubEmail: cEmail,
                    ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All fields are required")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF191C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Create Club", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditClubDialog(Map<String, dynamic> club) {
    _clubNameController.text = club['clubName']?.toString() ?? '';
    _facultyNameController.text = club['facultyName']?.toString() ?? '';
    _facultyEmailController.text = club['facultyEmail']?.toString() ?? '';
    _clubEmailController.text = club['clubEmail']?.toString() ?? '';

    final id = club['id']?.toString() ?? club['_id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("Edit ${club['clubName'] ?? 'Club'}", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _clubNameController,
                decoration: const InputDecoration(labelText: "Club Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _facultyNameController,
                decoration: const InputDecoration(labelText: "Faculty Coordinator Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _facultyEmailController,
                decoration: const InputDecoration(labelText: "Faculty Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _clubEmailController,
                decoration: const InputDecoration(labelText: "Club Email"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(UpdateAdminClubRequested(id, {
                    'clubName': _clubNameController.text.trim(),
                    'facultyName': _facultyNameController.text.trim(),
                    'facultyEmail': _facultyEmailController.text.trim(),
                    'clubEmail': _clubEmailController.text.trim(),
                  }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF191C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is AdminError) {
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
            "Campus Clubs",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_business, color: Colors.white),
              onPressed: _showCreateClubDialog,
              tooltip: "Create New Club",
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Map<String, dynamic>> clubs = [];
            if (state is AdminClubsLoaded) {
              clubs = state.clubs;
            }

            if (clubs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text("No clubs registered yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showCreateClubDialog,
                      icon: const Icon(Icons.add),
                      label: const Text("Create First Club"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF191C32)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminBloc>().add(const FetchAdminClubs());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final c = clubs[index];
                  final clubName = c['clubName']?.toString() ?? 'Campus Club';
                  final facultyName = c['facultyName']?.toString() ?? 'Faculty Coordinator';
                  final facultyEmail = c['facultyEmail']?.toString() ?? '';
                  final clubEmail = c['clubEmail']?.toString() ?? '';

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
                          radius: 24,
                          backgroundColor: const Color(0xFFFFEBE4),
                          child: Text(
                            clubName.isNotEmpty ? clubName[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(clubName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32))),
                              const SizedBox(height: 2),
                              Text("Faculty: $facultyName ($facultyEmail)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (clubEmail.isNotEmpty)
                                Text("Club Email: $clubEmail", style: const TextStyle(color: Color(0xFFF7931A), fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF191C32), size: 20),
                          onPressed: () => _showEditClubDialog(c),
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
