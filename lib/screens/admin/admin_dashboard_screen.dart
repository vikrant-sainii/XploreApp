import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/admin/admin_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'admin_clubs_screen.dart';
import 'admin_coordinators_screen.dart';
import 'admin_payouts_screen.dart';
import 'admin_export_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const FetchAdminStats());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String adminName = "System Admin";
    String adminEmail = "admin@nitj.ac.in";

    if (authState is Authenticated) {
      adminName = authState.user.name.isNotEmpty ? authState.user.name : "CN Admin";
      adminEmail = authState.user.email;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF191C32),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.shield, color: Color(0xFFF7931A), size: 24),
            const SizedBox(width: 8),
            const Text(
              "Central Admin Portal",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout Admin",
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          Map<String, dynamic> stats = {
            'totalRevenue': 24000,
            'totalStudents': 870,
            'totalClubs': 25,
            'totalEvents': 18,
            'totalEventsTillNow': 102,
          };
          List<Map<String, dynamic>> exportEvents = [];

          if (state is AdminDashboardLoaded) {
            stats = state.stats;
            exportEvents = state.exportEvents;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminBloc>().add(const FetchAdminStats());
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Admin Header Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191C32),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFFFEBE4),
                        child: Icon(Icons.admin_panel_settings, color: Color(0xFFF7931A), size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              adminEmail,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5FC88F),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "PLATFORM ADMIN",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Metrics Grid
                const Text(
                  "PLATFORM OVERVIEW",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1),
                ),
                const SizedBox(height: 12),

                if (state is AdminLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _metricTile("TOTAL REVENUE", "₹${stats['totalRevenue'] ?? 0}", Icons.currency_rupee, const Color(0xFF5FC88F)),
                      _metricTile("TOTAL STUDENTS", "${stats['totalStudents'] ?? 0}", Icons.people, const Color(0xFF191C32)),
                      _metricTile("TOTAL CLUBS", "${stats['totalClubs'] ?? 0}", Icons.groups, const Color(0xFFF7931A)),
                      _metricTile("ACTIVE EVENTS", "${stats['totalEvents'] ?? 0}", Icons.event, const Color(0xFF9F9DF3)),
                    ],
                  ),

                const SizedBox(height: 28),

                // Quick Admin Actions
                const Text(
                  "ADMIN CONTROL CENTER",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1),
                ),
                const SizedBox(height: 12),
                _adminActionTile(
                  title: "Campus Clubs Management",
                  subtitle: "Create, view & update campus clubs",
                  icon: Icons.business,
                  color: const Color(0xFF191C32),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminClubsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _adminActionTile(
                  title: "Faculty Coordinators",
                  subtitle: "Manage assigned faculty leads",
                  icon: Icons.school,
                  color: const Color(0xFFF7931A),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminCoordinatorsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _adminActionTile(
                  title: "Payouts & Financials",
                  subtitle: "Complete payouts for concluded events",
                  icon: Icons.payments,
                  color: const Color(0xFF5FC88F),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPayoutsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _adminActionTile(
                  title: "Event Data Export",
                  subtitle: "Generate flat reports & analytics",
                  icon: Icons.analytics,
                  color: const Color(0xFF9F9DF3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminExportScreen()),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Recent Event Exports Preview
                if (exportEvents.isNotEmpty) ...[
                  const Text(
                    "RECENT EVENT REPORTS",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 10),
                  ...exportEvents.take(3).map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFF7F7FA),
                              child: Icon(Icons.event_note, color: Color(0xFF191C32)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e['eventName']?.toString() ?? 'Event', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text("Club: ${e['clubName'] ?? 'General'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${e['totalRegistrations'] ?? 0} Joins", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF7931A))),
                                Text("₹${e['totalAmountReceived'] ?? 0}", style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _adminActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
