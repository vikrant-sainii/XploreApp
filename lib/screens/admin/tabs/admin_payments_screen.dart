import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/components/app_text_field.dart';
import 'package:xplore_app/config/theme.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState ||
        (bloc.state as AdminDataState).payments == null) {
      bloc.add(const FetchAdminPayments());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppTextField(
              controller: _searchCtrl,
              hintText: 'Search by name or UTR…',
              prefixIcon: Icons.search_rounded,
              height: 44,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: 10),
          // Status filter chips
          SizedBox(
            height: 36,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _statusChip('all', 'All'),
                const SizedBox(width: 8),
                _statusChip('pending', 'Pending'),
                const SizedBox(width: 8),
                _statusChip('approved', 'Verified'),
                const SizedBox(width: 8),
                _statusChip('rejected', 'Rejected'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                List<dynamic> payments = [];
                Map<String, dynamic>? summary;
                bool isLoading = false;

                if (state is AdminDataState) {
                  payments = state.payments ?? [];
                  summary = state.paymentsSummary;
                  isLoading = state.isLoading;
                }

                if (isLoading && payments.isEmpty) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }

                final filtered = payments.where((p) {
                  final name = (p['studentName'] ?? p['name'] ?? '')
                      .toString()
                      .toLowerCase();
                  final utr =
                      (p['transactionId'] ?? p['utrNumber'] ?? p['utr'] ?? '')
                          .toString()
                          .toLowerCase();
                  final status =
                      (p['paymentStatus'] ?? p['status'] ?? 'pending')
                          .toString()
                          .toLowerCase();
                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery) ||
                      utr.contains(_searchQuery);
                  final matchesStatus = _statusFilter == 'all' ||
                      status == _statusFilter ||
                      (_statusFilter == 'approved' &&
                          (status == 'verified' || status == 'success'));
                  return matchesSearch && matchesStatus;
                }).toList();

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardColor,
                  onRefresh: () async =>
                      context.read<AdminBloc>().add(const FetchAdminPayments()),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      // Summary banner
                      if (summary != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.15),
                                AppColors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryItem(
                                label: 'Total',
                                value:
                                    '${summary['totalCount'] ?? summary['total'] ?? 0}',
                                color: Colors.white,
                              ),
                              _SummaryItem(
                                label: 'Verified',
                                value:
                                    '${summary['verifiedCount'] ?? summary['approvedCount'] ?? 0}',
                                color: const Color(0xFF10B981),
                              ),
                              _SummaryItem(
                                label: 'Pending',
                                value: '${summary['pendingCount'] ?? 0}',
                                color: const Color(0xFFF59E0B),
                              ),
                              _SummaryItem(
                                label: 'Revenue',
                                value: '₹${summary['totalRevenue'] ?? 0}',
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (filtered.isEmpty)
                        const _EmptyPayments()
                      else
                        ...filtered.map((p) =>
                            _PaymentCard(payment: p as Map<String, dynamic>)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label) {
    final selected = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
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

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;

  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentCard({required this.payment});

  Color get _statusColor {
    final status = (payment['paymentStatus'] ?? payment['status'] ?? '')
        .toString()
        .toLowerCase();
    switch (status) {
      case 'verified':
      case 'approved':
      case 'success':
        return const Color(0xFF10B981);
      case 'rejected':
        return Colors.red.shade400;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = payment['studentName'] ?? payment['name'] ?? 'Unknown';
    final event = payment['eventName'] ?? payment['event']?['title'] ?? '';
    final utr = payment['transactionId'] ??
        payment['utrNumber'] ??
        payment['utr'] ??
        '—';
    final amount = payment['amountPaid'] ?? payment['amount'] ?? 0;
    final status =
        (payment['paymentStatus'] ?? payment['status'] ?? 'pending').toString();
    final rollNo = payment['studentRollNo'] ?? payment['rollNo'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                        name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      if (rollNo.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(rollNo,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            if (event.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                // UTR
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'UTR: $utr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹$amount',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPayments extends StatelessWidget {
  const _EmptyPayments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 40, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('No transactions found',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
