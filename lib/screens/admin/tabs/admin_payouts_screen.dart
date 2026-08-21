import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class AdminPayoutsScreen extends StatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  State<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends State<AdminPayoutsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState || (bloc.state as AdminDataState).stats == null) {
      bloc.add(const FetchAdminDashboardStats());
    }
  }

  void _showPayoutDialog(BuildContext context, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text('Confirm Payout',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark payout as complete for:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              event['title'] ?? 'Untitled Event',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: ₹${event['netRevenue'] ?? event['revenue'] ?? 0}',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Payout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          bool isLoading = false;
          List<dynamic> events = [];

          if (state is AdminDataState) {
            isLoading = state.isLoading;
            if (state.stats != null) {
              events = (state.stats!['eventStats'] as List? ?? [])
                  .where((e) =>
                      (e['isPaid'] == true || (e['totalRevenue'] ?? 0) > 0) &&
                      (e['payoutStatus'] != 'completed'))
                  .toList();
            }
          }

          if (isLoading && events.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (events.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardColor,
              onRefresh: () async =>
                  context.read<AdminBloc>().add(const FetchAdminDashboardStats()),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 48, color: Color(0xFF10B981)),
                        SizedBox(height: 12),
                        Text('All payouts are settled!',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(height: 4),
                        Text('No pending financial payouts',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardColor,
            onRefresh: () async =>
                context.read<AdminBloc>().add(const FetchAdminDashboardStats()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: events.length,
              itemBuilder: (context, i) {
                final event = events[i] as Map<String, dynamic>;
                return _PayoutCard(
                  event: event,
                  onPayout: () => _showPayoutDialog(context, event),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onPayout;

  const _PayoutCard({required this.event, required this.onPayout});

  @override
  Widget build(BuildContext context) {
    final title = event['title'] ?? 'Untitled';
    final club = event['clubName'] ?? event['club'] ?? '';
    final headName = event['headName'] ?? '';
    final totalReg = event['totalRegistrations'] ?? 0;
    final revenue = event['totalRevenue'] ?? event['netRevenue'] ?? 0;
    final payoutStatus =
        (event['payoutStatus'] ?? 'pending').toString().toLowerCase();
    final isPending = payoutStatus == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? AppColors.primary.withValues(alpha: 0.3)
              : const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (club.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(club,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                Text(
                  '₹$revenue',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoBadge(
                    icon: Icons.people_rounded, label: '$totalReg registrations'),
                if (headName.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  _InfoBadge(
                      icon: Icons.person_rounded, label: headName),
                ],
                const Spacer(),
                if (isPending)
                  ElevatedButton(
                    onPressed: onPayout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    child: const Text('Pay Out'),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'SETTLED',
                      style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
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

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
