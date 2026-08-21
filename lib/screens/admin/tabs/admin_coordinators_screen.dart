import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/components/admin_input_field.dart';
import 'package:xplore_app/config/theme.dart';

class AdminCoordinatorsScreen extends StatefulWidget {
  const AdminCoordinatorsScreen({super.key});

  @override
  State<AdminCoordinatorsScreen> createState() => _AdminCoordinatorsScreenState();
}

class _AdminCoordinatorsScreenState extends State<AdminCoordinatorsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState || (bloc.state as AdminDataState).coordinators == null) {
      bloc.add(const FetchAdminCoordinators());
    }
  }

  void _showAddCoordinatorSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add Coordinator',
                    style: TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdminInputField(controller: nameCtrl, label: 'Full Name', hint: 'Prof. John Doe'),
              const SizedBox(height: 14),
              AdminInputField(
                  controller: emailCtrl,
                  label: 'Email',
                  hint: 'faculty@college.edu',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              AdminInputField(
                  controller: passCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                    context.read<AdminBloc>().add(CreateAdminCoordinator({
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'password': passCtrl.text,
                    }));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Coordinator'),
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
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.scaffoldBackground,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back to Admin Portal',
              ),
              title: const Text(
                'Faculty Coordinators',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCoordinatorSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Coordinator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminDataState) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ));
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
              ));
            }
          }
        },
        builder: (context, state) {
          List<dynamic> coordinators = [];
          bool isLoading = false;

          if (state is AdminDataState) {
            coordinators = state.coordinators ?? [];
            isLoading = state.isLoading;
          }

          if (isLoading && coordinators.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (coordinators.isEmpty && !isLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.supervisor_account_rounded,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text('No coordinators added yet',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCoordinatorSheet(context),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Add Coordinator'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardColor,
            onRefresh: () async =>
                context.read<AdminBloc>().add(const FetchAdminCoordinators()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: coordinators.length,
              itemBuilder: (context, i) {
                final coord = coordinators[i] as Map<String, dynamic>;
                return _CoordinatorCard(coordinator: coord, index: i + 1);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CoordinatorCard extends StatelessWidget {
  final Map<String, dynamic> coordinator;
  final int index;

  const _CoordinatorCard({required this.coordinator, required this.index});

  @override
  Widget build(BuildContext context) {
    final name = coordinator['name'] ?? 'Unknown';
    final email = coordinator['email'] ?? '';
    final clubs = coordinator['clubs'] as List? ?? [];
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

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
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (clubs.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: clubs.take(3).map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c.toString(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            // Index badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
