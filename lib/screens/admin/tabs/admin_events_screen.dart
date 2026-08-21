import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminBloc>();
    if (bloc.state is! AdminDataState || (bloc.state as AdminDataState).events == null) {
      bloc.add(const FetchAdminEvents());
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
          // ── Search Bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
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
                        hintText: 'Search events…',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Type filter chip
                _FilterChip(
                  selected: _typeFilter == 'all',
                  label: 'All',
                  onTap: () => setState(() => _typeFilter = 'all'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  selected: _typeFilter == 'paid',
                  label: 'Paid',
                  onTap: () => setState(() => _typeFilter = 'paid'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Event List ─────────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                List<dynamic> events = [];
                bool isLoading = false;
                String? errorMessage;

                if (state is AdminDataState) {
                  events = state.events ?? [];
                  isLoading = state.isLoading;
                  errorMessage = state.errorMessage;
                }

                if (isLoading && events.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (errorMessage != null && events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.primary, size: 40),
                        const SizedBox(height: 12),
                        Text(errorMessage,
                            style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<AdminBloc>().add(const FetchAdminEvents()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Apply search + type filter
                final filtered = events.where((e) {
                  final title = (e['eventName'] ?? e['title'] ?? '').toString().toLowerCase();
                  final club = (e['clubName'] ?? e['club'] ?? '').toString().toLowerCase();
                  final matchesSearch = _searchQuery.isEmpty ||
                      title.contains(_searchQuery) ||
                      club.contains(_searchQuery);
                  final eventType = (e['eventType'] ?? '').toString().toLowerCase();
                  final isPaid = eventType == 'paid' || (e['entryFee'] ?? 0) > 0;
                  final matchesType = _typeFilter == 'all' ||
                      (_typeFilter == 'paid' && isPaid) ||
                      (_typeFilter == 'free' && !isPaid);
                  return matchesSearch && matchesType;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No events found',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardColor,
                  onRefresh: () async =>
                      context.read<AdminBloc>().add(const FetchAdminEvents()),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final e = filtered[i] as Map<String, dynamic>;
                      return _AdminEventCard(event: e, index: i);
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

class _FilterChip extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
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

class _AdminEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final int index;

  const _AdminEventCard({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    final title = event['eventName'] ?? event['title'] ?? 'Untitled Event';
    final club = event['clubName'] ?? event['club'] ?? '';
    final venue = event['venue'] ?? '';
    final totalReg = event['totalRegistrations'] ?? event['registeredCount'] ?? event['participantCount'] ?? 0;
    final imageUrl = event['imageUrl'] ?? event['imageLocation'] ?? event['image'] ?? '';
    final eventType = (event['eventType'] ?? '').toString().toLowerCase();
    final isPaid = eventType == 'paid' || (event['entryFee'] ?? 0) > 0;
    final revenue = event['totalAmountReceived'] ?? event['totalRevenue'] ?? event['revenue'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Index badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgFallback(),
                    )
                  : _imgFallback(),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    club.isNotEmpty ? club : (venue.isNotEmpty ? venue : 'No club info'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Stats column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '$totalReg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaid ? '₹$revenue' : 'Free',
                    style: TextStyle(
                      color: isPaid
                          ? const Color(0xFF10B981)
                          : AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.event_rounded,
            color: AppColors.textSecondary, size: 26),
      );
}
