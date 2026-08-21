import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/screens/admin/tabs/admin_overview_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_events_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_clubs_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_coordinators_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_payments_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_payouts_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_broadcasts_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_venues_screen.dart';
import 'package:xplore_app/screens/admin/tabs/admin_settings_screen.dart';

/// Navigation item descriptor
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool paymentAdminVisible;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.paymentAdminVisible = false,
  });
}

/// Full admin nav items
const _adminNavItems = [
  _NavItem(
    label: 'Overview',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
  ),
  _NavItem(
    label: 'Events',
    icon: Icons.event_outlined,
    activeIcon: Icons.event_rounded,
  ),
  _NavItem(
    label: 'Clubs',
    icon: Icons.groups_outlined,
    activeIcon: Icons.groups_rounded,
  ),
  _NavItem(
    label: 'Payments',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    paymentAdminVisible: true,
  ),
  _NavItem(
    label: 'Payouts',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet_rounded,
    paymentAdminVisible: true,
  ),
  _NavItem(
    label: 'More',
    icon: Icons.menu_rounded,
    activeIcon: Icons.menu_rounded,
  ),
];

/// Admin Portal — main shell with bottom nav + IndexedStack
class AdminPortalScreen extends StatefulWidget {
  final String adminRole;

  const AdminPortalScreen({super.key, required this.adminRole});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int _currentIndex = 0;

  bool get _isPaymentAdmin => widget.adminRole == 'paymentAdmin';

  // The full screens list (for admin role)
  late final List<Widget> _adminScreens = [
    const AdminOverviewScreen(),
    const AdminEventsScreen(),
    const AdminClubsScreen(),
    const AdminPaymentsScreen(),
    const AdminPayoutsScreen(),
    const _MoreMenuScreen(onNavigate: null), // placeholder; handled via drawer
  ];

  // The payment admin screens list
  late final List<Widget> _paymentAdminScreens = [
    const AdminPaymentsScreen(),
    const AdminPayoutsScreen(),
    const AdminSettingsScreen(),
  ];

  List<Widget> get _screens =>
      _isPaymentAdmin ? _paymentAdminScreens : _adminScreens;

  /// Visible nav items for current role
  List<_NavItem> get _visibleNavItems {
    if (_isPaymentAdmin) {
      return [
        const _NavItem(
          label: 'Transactions',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
        ),
        const _NavItem(
          label: 'Payouts',
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet_rounded,
        ),
        const _NavItem(
          label: 'Settings',
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ];
    }
    return _adminNavItems;
  }

  String get _currentTitle {
    if (_isPaymentAdmin) {
      const titles = ['Transactions', 'Payouts', 'Settings'];
      return titles[_currentIndex.clamp(0, titles.length - 1)];
    }
    const titles = [
      'Overview',
      'All Events',
      'Clubs',
      'Transactions',
      'Payouts',
      'Menu',
    ];
    return titles[_currentIndex.clamp(0, titles.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // ── Drawer (More Menu for admin role) ─────────────────────────────
      drawer: _isPaymentAdmin
          ? null
          : _AdminDrawer(
              onTap: (screen) {
                Navigator.pop(context); // close drawer
                if (screen == 'coordinators') {
                  _navigateToFullScreen(
                      context, const AdminCoordinatorsScreen());
                } else if (screen == 'broadcasts') {
                  _navigateToFullScreen(
                      context, const AdminBroadcastsScreen());
                } else if (screen == 'venues') {
                  _navigateToFullScreen(context, const AdminVenuesScreen());
                } else if (screen == 'settings') {
                  _navigateToFullScreen(
                      context, const AdminSettingsScreen());
                }
              },
            ),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex < _screens.length ? _currentIndex : 0,
            children: _screens,
          ),
          // Bottom Nav
          _AdminBottomNav(
            items: _visibleNavItems,
            currentIndex: _currentIndex,
            onTap: (i) {
              if (!_isPaymentAdmin && i == _visibleNavItems.length - 1) {
                // "More" — open drawer
                Scaffold.of(context).openDrawer();
              } else {
                setState(() => _currentIndex = i);
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToFullScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => BlocProvider.value(
                value: context.read<AdminBloc>(),
                child: screen,
              )),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String adminName = 'Admin';
    if (authState is Authenticated) adminName = authState.user.name;

    return AppBar(
      backgroundColor: AppColors.scaffoldBackground,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (!_isPaymentAdmin)
            Builder(
              builder: (ctx) => IconButton(
                padding: EdgeInsets.zero,
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 18),
                ),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (!_isPaymentAdmin) const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                _isPaymentAdmin ? 'Finance Desk' : 'Admin Panel',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Admin avatar
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              if (_isPaymentAdmin) {
                setState(
                    () => _currentIndex = _paymentAdminScreens.length - 1);
              } else {
                _navigateToFullScreen(context, const AdminSettingsScreen());
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              alignment: Alignment.center,
              child: Text(
                adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Admin Bottom Nav Bar ────────────────────────────────────────────────────
class _AdminBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const _AdminBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isActive = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Admin Drawer (More Menu) ─────────────────────────────────────────────────
class _AdminDrawer extends StatelessWidget {
  final Function(String) onTap;

  const _AdminDrawer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String adminName = 'Admin User';
    String adminEmail = 'admin@college.edu';
    if (authState is Authenticated) {
      adminName = authState.user.name;
      adminEmail = authState.user.email;
    }

    return Drawer(
      backgroundColor: AppColors.cardColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          adminEmail,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 12),

            // Menu items
            _DrawerItem(
              icon: Icons.supervisor_account_rounded,
              label: 'Coordinators',
              onTap: () => onTap('coordinators'),
            ),
            _DrawerItem(
              icon: Icons.campaign_rounded,
              label: 'Broadcasts',
              onTap: () => onTap('broadcasts'),
            ),
            _DrawerItem(
              icon: Icons.location_city_rounded,
              label: 'Venues',
              onTap: () => onTap('venues'),
            ),
            _DrawerItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => onTap('settings'),
            ),
            const Spacer(),

            // Sign out
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.red.shade900.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

/// Placeholder for "More" tab (shown in IndexedStack, but tapping opens drawer)
class _MoreMenuScreen extends StatelessWidget {
  final Function(String)? onNavigate;

  const _MoreMenuScreen({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SizedBox.shrink(),
    );
  }
}
