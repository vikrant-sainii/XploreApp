import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/components/admin_input_field.dart';
import 'package:xplore_app/config/theme.dart';

class AdminBroadcastsScreen extends StatefulWidget {
  const AdminBroadcastsScreen({super.key});

  @override
  State<AdminBroadcastsScreen> createState() => _AdminBroadcastsScreenState();
}

class _AdminBroadcastsScreenState extends State<AdminBroadcastsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState || (bloc.state as AdminDataState).broadcasts == null) {
      bloc.add(const FetchAdminBroadcasts());
    }
  }

  void _showComposeBroadcast(BuildContext context) {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String targetType = 'ALL_STUDENTS';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.campaign_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'New Broadcast',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Target type selector
                const Text(
                  'TARGET AUDIENCE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TargetChip(
                      label: 'All Students',
                      selected: targetType == 'ALL_STUDENTS',
                      onTap: () =>
                          setSheetState(() => targetType = 'ALL_STUDENTS'),
                    ),
                    const SizedBox(width: 8),
                    _TargetChip(
                      label: 'Event Participants',
                      selected: targetType == 'REGISTERED_STUDENTS',
                      onTap: () => setSheetState(
                          () => targetType = 'REGISTERED_STUDENTS'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AdminInputField(controller: titleCtrl, label: 'Title', hint: 'Broadcast title…'),
                const SizedBox(height: 14),
                AdminInputField(
                    controller: messageCtrl,
                    label: 'Message',
                    hint: 'Write your broadcast message…',
                    maxLines: 4),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty ||
                          messageCtrl.text.trim().isEmpty) {
                        return;
                      }
                      context.read<AdminBloc>().add(SendAdminBroadcast({
                        'targetType': targetType,
                        'title': titleCtrl.text.trim(),
                        'message': messageCtrl.text.trim(),
                      }));
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Broadcast'),
                  ),
                ),
              ],
            ),
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
                'Broadcast Communication',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeBroadcast(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('New Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
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
            }
          }
        },
        builder: (context, state) {
          List<dynamic> broadcasts = [];
          bool isLoading = false;

          if (state is AdminDataState) {
            broadcasts = state.broadcasts ?? [];
            isLoading = state.isLoading;
          }

          if (isLoading && broadcasts.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (broadcasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_rounded,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text('No broadcasts sent yet',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Tap the button below to compose one',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardColor,
            onRefresh: () async =>
                context.read<AdminBloc>().add(const FetchAdminBroadcasts()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: broadcasts.length,
              itemBuilder: (context, i) {
                final b = broadcasts[i] as Map<String, dynamic>;
                return _BroadcastCard(broadcast: b);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TargetChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final Map<String, dynamic> broadcast;

  const _BroadcastCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final title = broadcast['title'] ?? 'Untitled';
    final message = broadcast['message'] ?? '';
    final target = broadcast['targetType'] ?? 'ALL_STUDENTS';
    final sentAt = broadcast['createdAt'] ?? broadcast['sentAt'] ?? '';

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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: target == 'ALL_STUDENTS'
                        ? const Color(0xFF6366F1).withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    target == 'ALL_STUDENTS' ? 'ALL' : 'EVENT',
                    style: TextStyle(
                      color: target == 'ALL_STUDENTS'
                          ? const Color(0xFF6366F1)
                          : AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
            if (sentAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                sentAt.toString().split('T').first,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
