import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import '../head/head_portal_screen.dart';
import 'package:xplore_app/config/theme.dart';

class UserClubsScreen extends StatelessWidget {
  const UserClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Clubs",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Authenticated) {
            final memberships = state.user.memberships;
            if (memberships.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "You are not a member of any clubs yet.",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "MEMBER PORTALS",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...memberships.map((membership) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildClubTile(
                        context,
                        name: membership.clubName ?? "Unknown Club",
                        role: membership.role,
                        image: membership.clubLogo ?? "assets/gdgc.png",
                        isHead: membership.role.toUpperCase() == "HEAD",
                      ),
                    )),
              ],
            );
          }
          return const Center(
            child: Text(
              "Please log in to view your clubs.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        },
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
            MaterialPageRoute(builder: (_) => const HeadPortalScreen()),
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
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.scaffoldBackground,
              backgroundImage: image.startsWith('http://') || image.startsWith('https://')
                  ? NetworkImage(image)
                  : AssetImage(image) as ImageProvider,
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Role: $role",
                    style: TextStyle(
                      color: isHead ? AppColors.primary : AppColors.textSecondary,
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
              color: isHead ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
