import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/club_model.dart';
import '../../services/club_service.dart';
import 'club_details_screen.dart';

class XploreClubsPopupDialog extends StatefulWidget {
  const XploreClubsPopupDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Xplore Clubs",
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return const XploreClubsPopupDialog();
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<XploreClubsPopupDialog> createState() => _XploreClubsPopupDialogState();
}

class _XploreClubsPopupDialogState extends State<XploreClubsPopupDialog> {
  final ClubService _clubService = ClubService();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  Timer? _autoSwipeTimer;
  List<ClubModel> _clubs = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    try {
      final list = await _clubService.getAllClubs();
      if (mounted) {
        setState(() {
          _clubs = list;
          _isLoading = false;
        });
        if (list.isNotEmpty) {
          _startAutoSwipe();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAutoSwipe() {
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_clubs.isEmpty || !mounted) return;
      int nextPage = _currentPage + 1;
      if (nextPage >= _clubs.length) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _launchSocialUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri uri = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening $urlString..."), backgroundColor: const Color(0xFF191C32)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening $urlString..."), backgroundColor: const Color(0xFF191C32)),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF191C32).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white12, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Modal Header with Close Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NITJ Clubs & Societies 🏛️",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Explore student groups & connect with leads",
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: const CircleBorder(),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Auto-Swiping Cards Area
              if (_isLoading)
                const SizedBox(
                  height: 380,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFF7931A))),
                )
              else if (_clubs.isEmpty)
                const SizedBox(
                  height: 380,
                  child: Center(child: Text("No clubs found.", style: TextStyle(color: Colors.white54))),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      height: 420,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (idx) {
                          setState(() => _currentPage = idx);
                        },
                        itemCount: _clubs.length,
                        itemBuilder: (ctx, index) {
                          final club = _clubs[index];
                          return _buildClubPopupCard(context, club);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Page Indicator Dots & Navigation Arrows
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white70),
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                          Row(
                            children: List.generate(_clubs.length > 8 ? 8 : _clubs.length, (idx) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentPage == idx ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == idx ? const Color(0xFFF7931A) : Colors.white24,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                            onPressed: _currentPage < _clubs.length - 1
                                ? () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubPopupCard(BuildContext context, ClubModel club) {
    final String mottoText = club.motto ??
        (club.name.toUpperCase() == 'LADC'
            ? "\"Think. Express. Evolve\""
            : (club.name.toUpperCase() == 'KALAKAAR'
                ? "\"We don't take actors, we make actors.\""
                : ""));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cover Banner & Overlapping Logo Header
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    image: DecorationImage(
                      image: NetworkImage(club.bannerUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -24,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFFFEBE4),
                      backgroundImage: (club.image != null && club.image!.startsWith('http'))
                          ? NetworkImage(club.image!) as ImageProvider
                          : AssetImage(club.image ?? 'assets/gdgc.png'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7931A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (club.category ?? "STUDENT CLUB").toUpperCase(),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      if (club.establishedYear != null && club.establishedYear!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "Est. ${club.establishedYear}",
                            style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    club.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF191C32),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    "${club.category ?? 'Student'} Club, NIT Jalandhar",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  if (mottoText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      mottoText,
                      style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFFF7931A), fontWeight: FontWeight.w600),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Description snippet
                  Text(
                    club.description ?? "The official student group dedicated to community, innovation, and campus spirit.",
                    style: const TextStyle(color: Color(0xFF6E7191), fontSize: 12, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons & Social Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.instagram, size: 20, color: Color(0xFFE4405F)),
                            tooltip: "Open Instagram",
                            onPressed: () {
                              final insta = club.socialLinks.firstWhere(
                                (s) => s.platform.toUpperCase() == 'INSTAGRAM' || s.url.toLowerCase().contains('instagram'),
                                orElse: () => const SocialLinkModel(platform: 'INSTAGRAM', url: 'https://instagram.com/ladc_nitj'),
                              );
                              _launchSocialUrl(insta.url);
                            },
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.linkedin, size: 20, color: Color(0xFF0A66C2)),
                            tooltip: "Open LinkedIn",
                            onPressed: () {
                              final linkedin = club.socialLinks.firstWhere(
                                (s) => s.platform.toUpperCase() == 'LINKEDIN' || s.url.toLowerCase().contains('linkedin'),
                                orElse: () => const SocialLinkModel(platform: 'LINKEDIN', url: 'https://linkedin.com/company/ladc-nitj'),
                              );
                              _launchSocialUrl(linkedin.url);
                            },
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClubDetailsScreen(club: club),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                        label: const Text("View Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF191C32),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
