import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/models/coordinator_model.dart';
import 'package:xplore_app/widgets/app_primary_button.dart';
import 'package:xplore_app/widgets/app_text_field.dart';
import 'package:xplore_app/widgets/app_theme.dart';

class AdminCoordinatorsScreen extends StatefulWidget {
  const AdminCoordinatorsScreen({super.key});

  @override
  State<AdminCoordinatorsScreen> createState() =>
      _AdminCoordinatorsScreenState();
}

class _AdminCoordinatorsScreenState extends State<AdminCoordinatorsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCoordinators();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fetchCoordinators() {
    context.read<AdminBloc>().add(const FetchCoordinatorsRequested());
  }

  void _showCoordinatorDialog({CoordinatorModel? coordinator}) {
    final isEditing = coordinator != null;
    _nameController.text = coordinator?.name ?? '';
    _emailController.text = coordinator?.email ?? '';
    _passwordController.clear();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppThemeColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEditing ? 'Edit Faculty Coordinator' : 'Add Faculty Coordinator',
          style: const TextStyle(
            color: AppThemeColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Faculty Name',
                  hint: 'e.g. Dr. Faculty Name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) => value == null || value.trim().length < 2
                      ? 'Enter the faculty member name'
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _emailController,
                  label: 'Official Email',
                  hint: 'faculty@nitj.ac.in',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _passwordController,
                  label: isEditing
                      ? 'New Password (optional)'
                      : 'Initial Password (optional)',
                  hint: 'At least 8 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    return value.length < 8
                        ? 'Password must contain at least 8 characters'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel',
                style: TextStyle(color: AppThemeColors.mutedText)),
          ),
          SizedBox(
            width: 170,
            child: AppPrimaryButton(
              label: isEditing ? 'Save Changes' : 'Add Coordinator',
              icon: isEditing ? Icons.save_outlined : Icons.person_add_alt_1,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final name = _nameController.text.trim();
                final email = _emailController.text.trim().toLowerCase();
                final password = _passwordController.text;
                final data = <String, dynamic>{
                  'name': name,
                  'email': email,
                  if (password.isNotEmpty) 'password': password,
                };

                Navigator.pop(dialogContext);
                if (isEditing) {
                  context.read<AdminBloc>().add(
                        UpdateCoordinatorRequested(coordinator.id, data),
                      );
                } else {
                  context.read<AdminBloc>().add(
                        CreateCoordinatorRequested(
                          name: name,
                          email: email,
                          password: password.isEmpty ? null : password,
                        ),
                      );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Enter an official email address';
    final validFormat = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!validFormat) return 'Enter a valid email address';
    if (!email.endsWith('@nitj.ac.in'))
      return 'Use an @nitj.ac.in email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppThemeColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to admin dashboard',
        ),
        title: const Text(
          'Faculty Coordinators',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showCoordinatorDialog(),
            tooltip: 'Add faculty coordinator',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppThemeColors.mint,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading || state is AdminInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppThemeColors.orange),
            );
          }

          if (state is AdminError) {
            return _ErrorState(onRetry: _fetchCoordinators);
          }

          final coordinators = state is AdminCoordinatorsLoaded
              ? state.coordinators
              : const <CoordinatorModel>[];
          if (coordinators.isEmpty) {
            return _EmptyState(onAdd: () => _showCoordinatorDialog());
          }

          return RefreshIndicator(
            color: AppThemeColors.orange,
            onRefresh: () async => _fetchCoordinators(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              itemCount: coordinators.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final coordinator = coordinators[index];
                return _CoordinatorCard(
                  coordinator: coordinator,
                  onEdit: () =>
                      _showCoordinatorDialog(coordinator: coordinator),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CoordinatorCard extends StatelessWidget {
  final CoordinatorModel coordinator;
  final VoidCallback onEdit;

  const _CoordinatorCard({required this.coordinator, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final initial = coordinator.name.isEmpty
        ? 'F'
        : coordinator.name.trim()[0].toUpperCase();
    final hasImage = coordinator.profileImage?.startsWith('http') == true;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppThemeColors.softMint,
              backgroundImage:
                  hasImage ? NetworkImage(coordinator.profileImage!) : null,
              child: hasImage
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: AppThemeColors.mint,
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
                    coordinator.name.isEmpty ? 'Coordinator' : coordinator.name,
                    style: const TextStyle(
                      color: AppThemeColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coordinator.email,
                    style: const TextStyle(
                        color: AppThemeColors.mutedText, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      _RoleBadge(label: coordinator.displayRole),
                      if (coordinator.isTwoStepEnabled)
                        const _RoleBadge(label: '2FA ENABLED', mint: true),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: AppThemeColors.navy),
              tooltip: 'Edit coordinator',
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final bool mint;

  const _RoleBadge({required this.label, this.mint = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: mint ? AppThemeColors.softMint : AppThemeColors.softOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: mint ? AppThemeColors.mint : AppThemeColors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined,
                size: 52, color: AppThemeColors.mutedText),
            const SizedBox(height: 14),
            const Text(
              'No faculty coordinators found',
              style: TextStyle(color: AppThemeColors.mutedText, fontSize: 16),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 230,
              child: AppPrimaryButton(
                label: 'Add First Coordinator',
                icon: Icons.person_add_alt_1,
                onPressed: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 52, color: Colors.redAccent),
            const SizedBox(height: 14),
            const Text(
              'Unable to load coordinators',
              style: TextStyle(
                  color: AppThemeColors.navy, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 150,
              child: AppPrimaryButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
