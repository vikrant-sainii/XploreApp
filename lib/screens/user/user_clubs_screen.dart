import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/screens/user/club_details_screen.dart';
import 'package:xplore_app/screens/head/head_portal_screen.dart';
import 'package:xplore_app/screens/head/head_member_management_screen.dart';
import 'package:xplore_app/screens/head/head_announcements_screen.dart';

class UserClubsScreen extends StatefulWidget {
  final Function(int)? changeindex;
  const UserClubsScreen({super.key, this.changeindex});

  @override
  State<UserClubsScreen> createState() => _UserClubsScreenState();
}

class _UserClubsScreenState extends State<UserClubsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubBloc>().add(FetchAllClubs());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Campus Clubs & Hub",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: BlocBuilder<ClubBloc, ClubState>(
        builder: (context, state) {
          if (state is ClubLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClubError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClubBloc>().add(FetchAllClubs());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191C32),
                    ),
                    child: const Text("Retry", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          } else if (state is ClubsLoaded) {
            final userClubs = state.clubs;
            final allClubs = state.allClubs.isNotEmpty ? state.allClubs : state.clubs;

            final executiveClubs = userClubs.where((c) =>
                c.role.toUpperCase() == 'HEAD' ||
                c.role.toUpperCase() == 'CLUB_HEAD' ||
                c.role.toUpperCase() == 'COORDINATOR').toList();

            final joinedMemberClubs = userClubs.where((c) =>
                c.role.toUpperCase() == 'MEMBER').toList();

            final query = _searchQuery.toLowerCase().trim();
            final filteredAllClubs = query.isEmpty
                ? allClubs
                : allClubs.where((c) {
                    final name = c.name.toLowerCase();
                    final cat = (c.category ?? '').toLowerCase();
                    final desc = (c.description ?? '').toLowerCase();
                    return name.contains(query) || cat.contains(query) || desc.contains(query);
                  }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClubBloc>().add(FetchAllClubs());
              },
              child: ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search college clubs, societies...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),

                  // If not searching, show user's executive & joined clubs first
                  if (_searchQuery.isEmpty) ...[
                    if (executiveClubs.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "MY EXECUTIVE CLUB ROLES",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...executiveClubs.map((club) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildExecutiveClubCard(context, club),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (joinedMemberClubs.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "MY JOINED CLUBS",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...joinedMemberClubs.map((club) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildExploreClubTile(context, club, isMember: true),
                          )),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // ALL CAMPUS CLUBS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "ALL CAMPUS CLUBS",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Text(
                        "${filteredAllClubs.length} clubs",
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  if (filteredAllClubs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Text(
                        "No clubs found.",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    )
                  else
                    ...filteredAllClubs.map((club) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildExploreClubTile(context, club),
                        )),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildExecutiveClubCard(BuildContext context, ClubModel club) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFEBE4),
                backgroundImage: (club.image != null && club.image!.startsWith('http'))
                    ? NetworkImage(club.image!) as ImageProvider
                    : AssetImage(club.image ?? 'assets/gdgc.png'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF191C32)),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBE4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "ROLE: ${club.role.toUpperCase()}",
                        style: const TextStyle(color: Color(0xFFF7931A), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HeadPortalScreen(
                        clubId: club.id,
                        clubName: club.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard, size: 14, color: Colors.white),
                label: const Text("Dashboard", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF191C32)),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HeadMemberManagementScreen(clubId: club.id)),
                  );
                },
                icon: const Icon(Icons.group, size: 14, color: Color(0xFF191C32)),
                label: const Text("Team", style: TextStyle(color: Color(0xFF191C32), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HeadAnnouncementsScreen()),
                  );
                },
                icon: const Icon(Icons.campaign, size: 14, color: Color(0xFFF7931A)),
                label: const Text("Broadcasts", style: TextStyle(color: Color(0xFFF7931A), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreClubTile(BuildContext context, ClubModel club, {bool isMember = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClubDetailsScreen(club: club)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFF7F7FA),
              backgroundImage: (club.image != null && club.image!.startsWith('http'))
                  ? NetworkImage(club.image!) as ImageProvider
                  : AssetImage(club.image ?? 'assets/gdgc.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMember ? "Joined Member" : "Category: ${club.category ?? 'Technical'}",
                    style: TextStyle(
                      color: isMember ? const Color(0xFF5FC88F) : Colors.grey,
                      fontWeight: isMember ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF7F7FA), shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
