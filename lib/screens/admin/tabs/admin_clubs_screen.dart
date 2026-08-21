import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/components/admin_input_field.dart';
import 'package:xplore_app/config/theme.dart';

class AdminClubsScreen extends StatefulWidget {
  const AdminClubsScreen({super.key});

  @override
  State<AdminClubsScreen> createState() => _AdminClubsScreenState();
}

class _AdminClubsScreenState extends State<AdminClubsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState || (bloc.state as AdminDataState).clubs == null) {
      bloc.add(const FetchAdminClubs());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showCreateClubSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Create New Club',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdminInputField(controller: nameCtrl, label: 'Club Name', hint: 'e.g. GDG On Campus'),
              const SizedBox(height: 14),
              AdminInputField(controller: descCtrl, label: 'Description', hint: 'Brief description', maxLines: 3),
              const SizedBox(height: 14),
              AdminInputField(controller: emailCtrl, label: 'Head Email', hint: 'head@college.edu', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              AdminInputField(controller: passCtrl, label: 'Head Password', hint: '••••••••', obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                    context.read<AdminBloc>().add(CreateAdminClub({
                      'clubName': nameCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'clubEmail': emailCtrl.text.trim(),
                      'headPassword': passCtrl.text,
                    }));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Create Club'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClubSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Club', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search clubs…',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminDataState) {
                  if (state.successMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.successMessage!),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              builder: (context, state) {
                List<dynamic> clubs = [];
                bool isLoading = false;

                if (state is AdminDataState) {
                  clubs = state.clubs ?? [];
                  isLoading = state.isLoading;
                }

                if (isLoading && clubs.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }

                final filtered = clubs.where((c) {
                  final name = (c['clubName'] ?? c['name'] ?? '').toString().toLowerCase();
                  return _searchQuery.isEmpty || name.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No clubs found',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardColor,
                  onRefresh: () async =>
                      context.read<AdminBloc>().add(const FetchAdminClubs()),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final club = filtered[i] as Map<String, dynamic>;
                      return _ClubCard(club: club);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Map<String, dynamic> club;

  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final name = club['clubName'] ?? club['name'] ?? 'Unnamed Club';
    final logo = club['clubLogo'] ?? club['logo'] ?? '';
    
    // Check memberships for club head or facultyCoordinator
    String headName = club['headName'] ?? '';
    String headEmail = club['headEmail'] ?? club['clubEmail'] ?? '';
    
    if (headName.isEmpty && club['memberships'] is List && (club['memberships'] as List).isNotEmpty) {
      final headStudent = (club['memberships'] as List)[0]['student'];
      if (headStudent != null) {
        headName = headStudent['name'] ?? '';
        headEmail = headStudent['email'] ?? headEmail;
      }
    }
    if (headName.isEmpty && club['facultyCoordinator'] != null) {
      headName = club['facultyCoordinator']['name'] ?? '';
      headEmail = club['facultyCoordinator']['email'] ?? headEmail;
    }

    final memberCount = club['memberCount'] ?? club['totalMembers'] ?? (club['memberships'] is List ? (club['memberships'] as List).length : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Club logo
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: logo.startsWith('http')
                  ? Image.network(
                      logo,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoFallback(name),
                    )
                  : _logoFallback(name),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (headName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            headName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (headEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      headEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$memberCount',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'members',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback(String name) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}
