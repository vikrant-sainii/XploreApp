import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Adminpage.dart';

class ScreenX extends StatelessWidget {
  const ScreenX({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text(
          "My Clubs",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "MEMBER PORTALS",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildClubTile(
            context,
            name: "GDGC CLUB",
            role: "HEAD",
            image: "assets/gdgc.png",
            isHead: true,
          ),
          const SizedBox(height: 12),
          _buildClubTile(
            context,
            name: "OCTAVE CLUB",
            role: "MEMBER",
            image: "assets/octave.png",
            isHead: false,
          ),
          const SizedBox(height: 12),
          _buildClubTile(
            context,
            name: "BHANGRA CLUB",
            role: "MEMBER",
            image: "assets/bhangralogo.png",
            isHead: false,
          ),
        ],
      ),
    );
  }

  Widget _buildClubTile(
    BuildContext context, {
    required String name,
    required String role,
    required String image,
    required bool isHead,
  }) {
    return GestureDetector(
      onTap: () {
        if (isHead) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Access to $name (Member) interface.")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF7F7FA),
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF191C32),
                    ),
                  ),
                  Text(
                    "Role: $role",
                    style: TextStyle(
                      color: isHead ? Colors.orange : Colors.grey,
                      fontWeight: isHead ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: isHead ? const Color(0xFFF7931A) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
