import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screen2.dart';

class Adminscreen1 extends StatelessWidget {
  final Function(int) changeindex;
  const Adminscreen1({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadCard(context),
            const SizedBox(height: 32),
            const Text(
              "DASHBOARD",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardGrid(),
            const SizedBox(height: 32),
            _buildRecentActivities(),
            const SizedBox(height: 100), // Avoid being hidden by bottom nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
        tooltip: "Back to Student View",
      ),
      title: Row(
        children: [
          Image.asset("assets/gdgc.png", height: 40),
          const SizedBox(width: 8),
          const Text(
            "Head Portal",
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Screen2()),
            );
          },
          tooltip: "Logout",
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
          child: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.person_outline, size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCard(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D27),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "GDGC LEAD",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "NAME OF LEAD",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "Roll no of lead",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {}, // Clickable but no destination
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    "Member Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Image.asset(
                "assets/pose.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          "Event\nManagement",
          FontAwesomeIcons.cube,
          const Color(0xFF1D1D27),
          Colors.white,
        ),
        _buildActionCard(
          "Member\nManagement",
          FontAwesomeIcons.masksTheater,
          const Color(0xFFF8B6D1),
          const Color(0xFF1D1B20),
        ),
        _buildActionCard(
          "Make\nAnnouncements",
          FontAwesomeIcons.towerBroadcast,
          const Color(0xFFF8B6D1),
          const Color(0xFF1D1B20),
        ),
        _buildActionCard(
          "Task\nManagement",
          FontAwesomeIcons.creditCard,
          const Color(0xFF1D1D27),
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color bg, Color text) {
    return GestureDetector(
      onTap: () {}, // Clickable but no destination
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: text, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECENT ACTIVITIES",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B20),
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityTile(
          "Bhangra Workshop",
          "Venue : A3, Civil Building",
          "Mar 9 5.30 pm",
          "assets/bhangralogo.png",
        ),
        const SizedBox(height: 12),
        _buildActivityTile(
          "NETRA Exhibition",
          "Venue : Main Auditorium",
          "May 23 7pm",
          "assets/gdgc.png", // Fallback to gdgc icon if netra icon not available
        ),
      ],
    );
  }

  Widget _buildActivityTile(String title, String venue, String time, String asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF6F7FA),
            radius: 24,
            backgroundImage: AssetImage(asset),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  venue,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("See More Info", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Icon(Icons.keyboard_arrow_up, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
