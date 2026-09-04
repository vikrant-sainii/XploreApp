import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/components/admin_input_field.dart';
import 'package:xplore_app/components/app_primary_button.dart';
import 'package:xplore_app/config/theme.dart';

class AdminVenuesScreen extends StatefulWidget {
  const AdminVenuesScreen({super.key});

  @override
  State<AdminVenuesScreen> createState() => _AdminVenuesScreenState();
}

class _AdminVenuesScreenState extends State<AdminVenuesScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState ||
        (bloc.state as AdminDataState).venues == null) {
      bloc.add(const FetchAdminVenues());
    }
  }

  void _showAddVenueSheet(BuildContext context,
      {Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final locationCtrl =
        TextEditingController(text: existing?['location'] ?? '');
    final capacityCtrl =
        TextEditingController(text: existing?['capacity']?.toString() ?? '');
    final descCtrl =
        TextEditingController(text: existing?['description'] ?? '');
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEdit ? 'Edit Venue' : 'Add Venue',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdminInputField(
                  controller: nameCtrl,
                  label: 'Venue Name',
                  hint: 'e.g. Auditorium'),
              const SizedBox(height: 14),
              AdminInputField(
                  controller: locationCtrl,
                  label: 'Location / Block',
                  hint: 'e.g. Block A'),
              const SizedBox(height: 14),
              AdminInputField(
                controller: capacityCtrl,
                label: 'Capacity',
                hint: 'e.g. 500',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              AdminInputField(
                  controller: descCtrl,
                  label: 'Description (optional)',
                  hint: 'Brief description…',
                  maxLines: 2),
              const SizedBox(height: 24),
              AppPrimaryButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final data = {
                    'name': nameCtrl.text.trim(),
                    'location': locationCtrl.text.trim(),
                    'capacity': int.tryParse(capacityCtrl.text) ?? 0,
                    'description': descCtrl.text.trim(),
                  };
                  if (existing != null) {
                    final id = existing['_id'] ?? existing['id'] ?? '';
                    context
                        .read<AdminBloc>()
                        .add(UpdateAdminVenue(id.toString(), data));
                  } else {
                    context.read<AdminBloc>().add(CreateAdminVenue(data));
                  }
                  Navigator.pop(ctx);
                },
                label: isEdit ? 'Update Venue' : 'Add Venue',
                height: 52,
                radius: 16,
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
                'Venues Management',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVenueSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Venue',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
          List<dynamic> venues = [];
          bool isLoading = false;

          if (state is AdminDataState) {
            venues = state.venues ?? [];
            isLoading = state.isLoading;
          }

          if (isLoading && venues.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (venues.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_city_rounded,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text('No venues configured',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVenueSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add First Venue'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardColor,
            onRefresh: () async =>
                context.read<AdminBloc>().add(const FetchAdminVenues()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: venues.length,
              itemBuilder: (context, i) {
                final venue = venues[i] as Map<String, dynamic>;
                return _VenueCard(
                  venue: venue,
                  onEdit: () => _showAddVenueSheet(context, existing: venue),
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Delete Venue',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        content: Text(
                          'Delete "${venue['name']}"? This cannot be undone.',
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel',
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              final id = venue['_id'] ?? venue['id'] ?? '';
                              context
                                  .read<AdminBloc>()
                                  .add(DeleteAdminVenue(id.toString()));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final Map<String, dynamic> venue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VenueCard(
      {required this.venue, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = venue['name'] ?? 'Unnamed Venue';
    final location = venue['location'] ?? '';
    final capacity = venue['capacity'] ?? 0;
    final description = venue['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_city_rounded,
                      color: Color(0xFF6366F1), size: 22),
                ),
                const SizedBox(width: 12),
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
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(location,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  color: AppColors.surface,
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              size: 16, color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: Colors.red.shade400)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people_rounded,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Capacity: $capacity',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
