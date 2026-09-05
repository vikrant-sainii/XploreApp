import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown_live/markdown_live.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/club/club_bloc.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../services/club_service.dart';
import 'user_event_details_screen.dart';

class ClubDetailsScreen extends StatefulWidget {
  final ClubModel club;
  final Function(int)? changeindex;

  const ClubDetailsScreen({super.key, required this.club, this.changeindex});

  @override
  State<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen> {
  final ClubService _clubService = ClubService();
  bool _isLoading = true;
  ClubModel? _fullClub;
  List<EventModel> _clubEvents = [];
  List<ClubMembershipModel> _members = [];

  bool _isDescriptionExpanded = false;

  // Controllers for editing club settings
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _facultyNameController = TextEditingController();
  final TextEditingController _facultyEmailController = TextEditingController();
  final TextEditingController _clubEmailController = TextEditingController();
  final TextEditingController _studentLeadController = TextEditingController();
  final TextEditingController _mottoController = TextEditingController();
  final TextEditingController _establishedYearController = TextEditingController();
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();
  final TextEditingController _bannerController = TextEditingController();
  final TextEditingController _galleryController = TextEditingController();
  final TextEditingController _sponsorsController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClubDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _facultyNameController.dispose();
    _facultyEmailController.dispose();
    _clubEmailController.dispose();
    _studentLeadController.dispose();
    _mottoController.dispose();
    _establishedYearController.dispose();
    _missionController.dispose();
    _descController.dispose();
    _logoController.dispose();
    _bannerController.dispose();
    _galleryController.dispose();
    _sponsorsController.dispose();
    _instaController.dispose();
    _linkedInController.dispose();
    _twitterController.dispose();
    _websiteController.dispose();
    _whatsappController.dispose();
    _githubController.dispose();
    super.dispose();
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

  Future<void> _loadClubDetails() async {
    try {
      final res = await _clubService.getClubDetails(widget.club.id);
      List<ClubMembershipModel> membersList = [];
      try {
        membersList = await _clubService.getClubMembers(widget.club.id);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _fullClub = res['club'] as ClubModel? ?? widget.club;
          _clubEvents = res['events'] as List<EventModel>? ?? [];
          _members = membersList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fullClub = widget.club;
          _isLoading = false;
        });
      }
    }
  }

  void _showEditClubModal(ClubModel club) {
    _nameController.text = club.name;
    _categoryController.text = club.category ?? "Literature";
    _facultyNameController.text = club.facultyName ?? "Dr. Shveta Mahajan";
    _facultyEmailController.text = club.facultyEmail ?? "";
    _clubEmailController.text = club.clubEmail ?? "";
    final heads = _members.where((m) => m.role.toUpperCase() == 'HEAD' || m.role.toUpperCase() == 'CLUB_HEAD').toList();
    _studentLeadController.text = heads.isNotEmpty ? heads.first.studentName : "SIMRAN MAURYA";
    _mottoController.text = club.motto ?? "Think. Express. Evolve.";
    _establishedYearController.text = club.establishedYear ?? "2017";
    _missionController.text = club.mission ?? "Empowering engineering students to conquer public speaking anxiety, sharpen their writing, and evolve into authoritative leaders through critical thinking and professional expression.";
    _descController.text = club.description ?? "What is LADC NITJ??\n\nThe Literary and Debating Club (LADC) is one of the oldest and most active student societies at Dr. B. R. Ambedkar National Institute of Technology, Jalandhar (NITJ). It serves as the primary hub for public speaking, creative writing, intellectual discourse, and literary arts on campus.\n\n### Core Philosophy\n* **Motto**: Think, Express, Evolve.\n* **Vision**: Cultivate critical thinking, open-mindedness, and exceptional communication skills among engineering students.";
    _logoController.text = club.image ?? "";
    _bannerController.text = club.bannerImage ?? "";
    _galleryController.text = club.clubGallery.join(', ');
    _sponsorsController.text = club.clubSponsors.join(', ');

    String findSocial(String keyword) {
      for (final link in club.socialLinks) {
        final p = link.platform.toLowerCase();
        final u = link.url.toLowerCase();
        if (p.contains(keyword) || u.contains(keyword)) {
          return link.url;
        }
      }
      return '';
    }

    _instaController.text = findSocial('insta');
    _linkedInController.text = findSocial('linkedin');
    _twitterController.text = findSocial('twitter');
    _websiteController.text = findSocial('website') != '' ? findSocial('website') : findSocial('portfolio');
    _whatsappController.text = findSocial('whatsapp');
    _githubController.text = findSocial('github');

    final List<String> history = [_descController.text];
    int historyIndex = 0;
    bool isUndoRedoAction = false;

    final markdownLiveController = MarkdownLiveController(
      text: _descController.text,
    );
    markdownLiveController.theme = MarkdownLiveTheme.light();

    markdownLiveController.addListener(() {
      if (isUndoRedoAction) return;
      final currentText = markdownLiveController.text;
      if (historyIndex >= 0 && historyIndex < history.length && history[historyIndex] == currentText) {
        return;
      }
      if (historyIndex < history.length - 1) {
        history.removeRange(historyIndex + 1, history.length);
      }
      history.add(currentText);
      historyIndex = history.length - 1;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bool canUndo = historyIndex > 0;
          final bool canRedo = historyIndex < history.length - 1;

          void handleUndo() {
            if (historyIndex > 0) {
              isUndoRedoAction = true;
              historyIndex--;
              final newText = history[historyIndex];
              markdownLiveController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
              isUndoRedoAction = false;
              setModalState(() {});
            }
          }

          void handleRedo() {
            if (historyIndex < history.length - 1) {
              isUndoRedoAction = true;
              historyIndex++;
              final newText = history[historyIndex];
              markdownLiveController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
              isUndoRedoAction = false;
              setModalState(() {});
            }
          }

          return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Drag Indicator Bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Club Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF191C32),
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Form Body
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Club Name & Category
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: _editInputDecoration("CLUB NAME"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _categoryController,
                                    decoration: _editInputDecoration("CATEGORY"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Faculty Coordinator & Student Lead
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _facultyNameController,
                                    decoration: _editInputDecoration("FACULTY COORDINATOR"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _studentLeadController,
                                    decoration: _editInputDecoration("STUDENT LEAD / CLUB HEAD"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Motto & Established Year
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _mottoController,
                                    decoration: _editInputDecoration("CLUB MOTTO / SLOGAN"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _establishedYearController,
                                    keyboardType: TextInputType.number,
                                    decoration: _editInputDecoration("ESTABLISHED YEAR"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Mission Statement
                            TextField(
                              controller: _missionController,
                              maxLines: 2,
                              decoration: _editInputDecoration("CLUB MISSION STATEMENT"),
                            ),
                            const SizedBox(height: 16),

                            // Description Section Header & Markdown Live Toolbar & Editor
                            const Text(
                              "CLUB MISSION / DESCRIPTION",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  // Markdown Live Toolbar with Horizontal Scroll (Fixes Overflow) & Undo/Redo
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                    ),
                                    child: Row(
                                      children: [
                                        // Scrollable Toolbar to prevent overflow
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: MarkdownLiveToolbar(
                                              controller: markdownLiveController,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(height: 18, width: 1, color: Colors.grey.shade300),
                                        const SizedBox(width: 4),

                                        // Undo Option
                                        IconButton(
                                          icon: Icon(Icons.undo, size: 16, color: canUndo ? const Color(0xFF191C32) : Colors.grey.shade400),
                                          tooltip: "Undo",
                                          onPressed: canUndo ? () => handleUndo() : null,
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                        ),

                                        // Redo Option
                                        IconButton(
                                          icon: Icon(Icons.redo, size: 16, color: canRedo ? const Color(0xFF191C32) : Colors.grey.shade400),
                                          tooltip: "Redo",
                                          onPressed: canRedo ? () => handleRedo() : null,
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Markdown Live Editor Box
                                  Container(
                                    constraints: const BoxConstraints(minHeight: 180),
                                    padding: const EdgeInsets.all(12),
                                    child: MarkdownLiveEditor(
                                      controller: markdownLiveController,
                                      theme: MarkdownLiveTheme.light(),
                                      onChanged: (text) {
                                        _descController.text = text;
                                        setModalState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                          // Image & Banner URLs
                          TextField(
                            controller: _logoController,
                            decoration: _editInputDecoration("CLUB LOGO URL / ASSET PATH", hintText: "assets/gdgc.png or https://..."),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _bannerController,
                            decoration: _editInputDecoration("COVER / BANNER IMAGE URL", hintText: "https://..."),
                          ),

                          const SizedBox(height: 16),

                          // MEDIA & VISUALS Header (Matching Design Screenshot)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "MEDIA & VISUALS",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
                              ),
                              Text(
                                "Logo is managed via Profile",
                                style: TextStyle(fontSize: 10, color: Color(0xFFF7931A), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Gallery Images Field (Comma separated)
                          TextField(
                            controller: _galleryController,
                            maxLines: 2,
                            decoration: _editInputDecoration(
                              "GALLERY IMAGES (COMMA SEPARATED URLS)",
                              hintText: "https://media.istockphoto.com/image1.jpg, https://media.istockphoto.com/image2.jpg",
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Sponsors Images Field (Comma separated)
                          TextField(
                            controller: _sponsorsController,
                            maxLines: 2,
                            decoration: _editInputDecoration(
                              "CLUB SPONSORS (COMMA SEPARATED URLS)",
                              hintText: "https://www.jankaritag.in/logo.png, https://static.wikia.nocookie.net/logo.png",
                            ),
                          ),
                          const SizedBox(height: 18),

                          // PUBLIC PRESENCE Header
                          const Text(
                            "PUBLIC PRESENCE",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 10),

                          // Social Links Row 1 (Instagram & LinkedIn)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _instaController,
                                  decoration: _editInputDecoration("INSTAGRAM URL", hintText: "https://instagram.com/handle"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _linkedInController,
                                  decoration: _editInputDecoration("LINKEDIN URL", hintText: "https://in.linkedin.com/company/handle"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Social Links Row 2 (X / Twitter & Website URL)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _twitterController,
                                  decoration: _editInputDecoration("X / TWITTER URL", hintText: "https://x.com/club"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _websiteController,
                                  decoration: _editInputDecoration("WEBSITE URL", hintText: "https://yourclub.org"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Social Links Row 3 (WhatsApp & GitHub)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _whatsappController,
                                  decoration: _editInputDecoration("WHATSAPP GROUP/NO.", hintText: "9783002110"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _githubController,
                                  decoration: _editInputDecoration("GITHUB URL", hintText: "https://github.com/club"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        _descController.text = markdownLiveController.text;
                        final messenger = ScaffoldMessenger.of(context);

                        final galleryList = _galleryController.text
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();
                        final sponsorsList = _sponsorsController.text
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        final socialLinksList = [
                          if (_instaController.text.trim().isNotEmpty)
                            SocialLinkModel(platform: 'instagram', url: _instaController.text.trim()),
                          if (_linkedInController.text.trim().isNotEmpty)
                            SocialLinkModel(platform: 'linkedin', url: _linkedInController.text.trim()),
                          if (_twitterController.text.trim().isNotEmpty)
                            SocialLinkModel(platform: 'twitter', url: _twitterController.text.trim()),
                          if (_websiteController.text.trim().isNotEmpty)
                            SocialLinkModel(platform: 'website', url: _websiteController.text.trim()),
                          if (_whatsappController.text.trim().isNotEmpty)
                            SocialLinkModel(platform: 'whatsapp', url: _whatsappController.text.trim()),
                          if (_githubController.text.trim().isNotEmpty)
                            SocialLinkModel(platform: 'github', url: _githubController.text.trim()),
                        ];

                        final updatedClub = club.copyWith(
                          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : club.name,
                          category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : club.category,
                          facultyName: _facultyNameController.text.trim().isNotEmpty ? _facultyNameController.text.trim() : club.facultyName,
                          motto: _mottoController.text.trim().isNotEmpty ? _mottoController.text.trim() : club.motto,
                          establishedYear: _establishedYearController.text.trim().isNotEmpty ? _establishedYearController.text.trim() : club.establishedYear,
                          mission: _missionController.text.trim().isNotEmpty ? _missionController.text.trim() : club.mission,
                          description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : club.description,
                          image: _logoController.text.trim().isNotEmpty ? _logoController.text.trim() : club.image,
                          bannerImage: _bannerController.text.trim().isNotEmpty ? _bannerController.text.trim() : club.bannerImage,
                          clubGallery: galleryList,
                          clubSponsors: sponsorsList,
                          socialLinks: socialLinksList,
                        );

                        setState(() {
                          _fullClub = updatedClub;
                        });

                        final updateData = <String, dynamic>{
                          'name': _nameController.text.trim(),
                          'clubName': _nameController.text.trim(),
                          'category': _categoryController.text.trim(),
                          'facultyName': _facultyNameController.text.trim(),
                          'motto': _mottoController.text.trim(),
                          'establishedYear': _establishedYearController.text.trim(),
                          'mission': _missionController.text.trim(),
                          'description': _descController.text.trim(),
                          if (_logoController.text.isNotEmpty) 'clubLogo': _logoController.text.trim(),
                          if (_logoController.text.isNotEmpty) 'image': _logoController.text.trim(),
                          if (_bannerController.text.isNotEmpty) 'bannerImage': _bannerController.text.trim(),
                          'clubGallery': galleryList,
                          'media': galleryList.map((url) => {'url': url}).toList(),
                          'clubSponsors': sponsorsList,
                          'sponsors': sponsorsList.map((url) => {'logoUrl': url, 'url': url}).toList(),
                          'socialLinks': socialLinksList.map((s) => s.toJson()).toList(),
                        };

                        if (ctx.mounted) Navigator.pop(ctx);
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Club profile updated successfully!"), backgroundColor: Colors.green),
                        );

                        final clubBloc = BlocProvider.of<ClubBloc>(context);
                        try {
                          await _clubService.updateClub(club.id, updateData);
                          _loadClubDetails();
                          if (mounted) {
                            clubBloc.add(FetchAllClubs());
                          }
                        } catch (_) {}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7931A),
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: const Text(
                        "SAVE CLUB PROFILE",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);
  }

InputDecoration _editInputDecoration(String labelText, {String? hintText}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFF7931A), width: 1.5),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final club = _fullClub ?? widget.club;

    final authState = context.watch<AuthBloc>().state;
    UserModel? user;
    if (authState is Authenticated) user = authState.user;

    // Check if user has management/executive rights for THIS SPECIFIC CLUB
    final bool isExecutive = user != null &&
        (user.isAdmin ||
            user.isClubAccount ||
            (user.clubId != null && user.clubId == club.id) ||
            (club.clubEmail != null &&
                club.clubEmail!.isNotEmpty &&
                user.email.toLowerCase() == club.clubEmail!.toLowerCase()) ||
            user.memberships.any((m) =>
                m.clubId == club.id &&
                (m.role.toUpperCase() == 'HEAD' ||
                    m.role.toUpperCase() == 'CLUB_HEAD' ||
                    m.role.toUpperCase() == 'COORDINATOR')));

    final upcomingEvents = _clubEvents.where((e) => e.status != 'COMPLETED').toList();
    final pastEvents = _clubEvents.where((e) => e.status == 'COMPLETED').toList();

    final heads = _members.where((m) => m.role.toUpperCase() == 'HEAD' || m.role.toUpperCase() == 'CLUB_HEAD').toList();
    final coords = _members.where((m) => m.role.toUpperCase() == 'COORDINATOR').toList();
    final generalMembers = _members.where((m) => m.role.toUpperCase() == 'MEMBER').toList();

    final String studentLeadName = heads.isNotEmpty ? heads.first.studentName : "Not Assigned";
    final String facultyName = (club.facultyName != null && club.facultyName!.isNotEmpty) ? club.facultyName! : "Faculty Coordinator";

    final String mottoText = club.motto ??
        (club.name.toUpperCase() == 'LADC'
            ? "Think • Express • Evolve"
            : (club.name.toUpperCase() == 'KALAKAAR'
                ? "We don't take actors, we make actors."
                : "Think • Build • Innovate • Together"));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF7931A)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top Hero Header Banner Container with Rounded Bottom Corners
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF191C32),
                      ),
                      child: Stack(
                        children: [
                          // 1. Blurred Background Image (Fills full container height & width with matching colors)
                          Positioned.fill(
                            child: Image.network(
                              club.bannerUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF191C32)),
                            ),
                          ),
                          Positioned.fill(
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),

                          // 2. Full Uncropped Banner Image (BoxFit.contain so 100% of narrow banner is fully visible)
                          Positioned.fill(
                            child: Image.network(
                              club.bannerUrl,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),

                          // 3. Dark Overlay Gradient for High Contrast Text & Buttons
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.55),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          // 3. Header Content Column (Top Nav + Bottom Club Profile Info)
                          SafeArea(
                            bottom: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Top Navigation Bar
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, top:0 , bottom: 6),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 18,
                                        child: IconButton(
                                          iconSize: 18,
                                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                                          onPressed: () {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            } else if (widget.changeindex != null) {
                                              widget.changeindex!(0);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          club.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      CircleAvatar(
                                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                                        radius: 18,
                                        child: IconButton(
                                          iconSize: 16,
                                          icon: const Icon(Icons.share, color: Colors.white),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Share link for ${club.name} copied!"),
                                                backgroundColor: const Color(0xFF191C32),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                                        radius: 18,
                                        child: IconButton(
                                          iconSize: 18,
                                          icon: const Icon(Icons.more_vert, color: Colors.white),
                                          onPressed: () {
                                            if (isExecutive) {
                                              _showEditClubModal(club);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("${club.name} • Official NITJ Student Group"),
                                                  backgroundColor: const Color(0xFF191C32),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 80),

                                // Bottom Club Profile Banner Info (Logo, Category Tag, Club Name & Stylized Motto)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          radius: 34,
                                          backgroundColor: const Color(0xFFFFEBE4),
                                          backgroundImage: (club.image != null && club.image!.startsWith('http'))
                                              ? NetworkImage(club.image!) as ImageProvider
                                              : AssetImage(club.image ?? 'assets/gdgc.png'),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF7931A),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                (club.category ?? "STUDENT CLUB").toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              club.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              "\"$mottoText\"",
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "NITJ",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Stats Metrics Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _statCard("ACTIVE MEMBERS", "${_members.length}", Icons.group),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statCard("LIVE & UPCOMING", "${upcomingEvents.length}", Icons.event_available),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statCard("PAST EVENTS", "${pastEvents.length}", Icons.history),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Edit Club Details Banner Card (Matching Image 1)
                        if (isExecutive) ...[
                          GestureDetector(
                            onTap: () => _showEditClubModal(club),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFFFEBE4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFEBE4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Color(0xFFF7931A),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Edit Club Details",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF191C32),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Update information, highlights and more",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFF7931A),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // About Club Section
                        const Text(
                          "ABOUT THE CLUB",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                ),
                const SizedBox(height: 10),

                // Mission Callout (Only if LADC)
                if (club.name.toUpperCase() == 'LADC') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBE4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF7931A).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("CLUB MISSION 🎯", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF7931A))),
                        SizedBox(height: 4),
                        Text(
                          "\"Empowering engineering students to conquer public speaking anxiety, sharpen their writing, and evolve into authoritative leaders through critical thinking and professional expression.\"",
                          style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Color(0xFF191C32), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Full Overview Container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final descText = club.description ?? "The official student group dedicated to community, innovation, and campus spirit.";
                          final bool isLongDescription = descText.length > 250 || descText.split('\n').length > 5;

                          final Widget markdownWidget = MarkdownBody(
                            data: descText,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Color(0xFF6E7191), fontSize: 13, height: 1.55),
                              strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C32)),
                              h1: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32), height: 1.4),
                              h2: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C32), height: 1.4),
                              h3: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C32), height: 1.4),
                              listBullet: const TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold, fontSize: 13),
                              blockSpacing: 10.0,
                            ),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLongDescription && !_isDescriptionExpanded)
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 160,
                                      child: ClipRect(
                                        child: SingleChildScrollView(
                                          physics: const NeverScrollableScrollPhysics(),
                                          child: markdownWidget,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      height: 65,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withValues(alpha: 0.0),
                                              Colors.white.withValues(alpha: 0.85),
                                              Colors.white,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                markdownWidget,
                              if (isLongDescription) ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded = !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isDescriptionExpanded ? "Read Less" : "Read More",
                                          style: const TextStyle(
                                            color: Color(0xFFF7931A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: const Color(0xFFF7931A),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("FACULTY COORDINATOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(facultyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191C32))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("STUDENT COORDINATOR / LEAD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(studentLeadName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191C32))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Connect Social Channels
                const Text(
                  "CONNECT & SOCIAL CHANNELS",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Connect with ${club.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C32))),
                          const Text("Follow our official social handles", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F), size: 22),
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
                            icon: const FaIcon(FontAwesomeIcons.linkedin, color: Color(0xFF0A66C2), size: 22),
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Club Events Section
                const Text(
                  "CLUB EVENTS & CALENDAR",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                ),
                const SizedBox(height: 12),

                if (_clubEvents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text("NO UPCOMING EVENTS SCHEDULED RIGHT NOW.", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ),
                  )
                else
                  ..._clubEvents.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFDEF5E9),
                              backgroundImage: (e.imageUrl != null && e.imageUrl!.startsWith('http'))
                                  ? NetworkImage(e.imageUrl!) as ImageProvider
                                  : AssetImage(e.imageLocation),
                            ),
                            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text(e.subtitle, style: const TextStyle(color: Color(0xFF9395A4), fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFF7931A)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserEventDetailsScreen(
                                      changeindex: (_) {},
                                      preview: EventDraft.no,
                                      event: e,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )),

                const SizedBox(height: 24),

                // Club Leadership & Team Section
                const Text(
                  "CLUB LEADERSHIP & TEAM",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                ),
                const SizedBox(height: 4),
                const Text("Guiding faculty, student coordinators, and active members", style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),

                // Faculty Coordinator Card (Dynamic from club backend)
                _teamMemberCard(
                  name: facultyName,
                  roleTag: "FACULTY COORDINATOR",
                  subtitle: club.facultyEmail ?? "${facultyName.toLowerCase().replaceAll(' ', '')}@nitj.ac.in",
                  isFaculty: true,
                ),

                const SizedBox(height: 10),

                // Student Leads (Dynamic from _members)
                if (heads.isNotEmpty)
                  ...heads.map((m) => _teamMemberCard(
                        name: m.studentName,
                        roleTag: "STUDENT LEAD",
                        subtitle: "${m.branch} • Year ${m.year}",
                      )),

                // Coordinators (Dynamic from _members)
                if (coords.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text("COORDINATORS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: coords
                        .map((c) => _teamMemberMiniCard(c.studentName, "COORDINATOR", "${c.branch} • Year ${c.year}"))
                        .toList(),
                  ),
                ],

                // Members (Dynamic from _members)
                if (generalMembers.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text("CLUB MEMBERS (${generalMembers.length})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: generalMembers
                        .map((m) => _teamMemberMiniCard(m.studentName, "Member", "${m.branch} • Year ${m.year}"))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 28),

                // Club Gallery Section (Dynamic)
                if (club.clubGallery.isNotEmpty) ...[
                  const Text(
                    "CLUB GALLERY",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: club.clubGallery.length,
                      itemBuilder: (ctx, idx) {
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(club.clubGallery[idx]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Sponsors Section (Dynamic)
                if (club.clubSponsors.isNotEmpty) ...[
                  const Text(
                    "SPONSORS & PARTNERS",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: club.clubSponsors.map((url) {
                        return Image.network(url, height: 35, errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Colors.grey));
                      }).toList(),
                    ),
                  ),
                ],

                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFF7931A), size: 18),
          const SizedBox(height: 6),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32))),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _teamMemberCard({required String name, required String roleTag, required String subtitle, bool isFaculty = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isFaculty ? const Color(0xFFFFEBE4) : const Color(0xFFDEF5E9),
            child: Text(
              name.isNotEmpty ? name[0] : 'U',
              style: TextStyle(color: isFaculty ? const Color(0xFFF7931A) : const Color(0xFF5FC88F), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191C32))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFaculty ? const Color(0xFFFFEBE4) : const Color(0xFFDEF5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    roleTag,
                    style: TextStyle(
                      color: isFaculty ? const Color(0xFFF7931A) : const Color(0xFF5FC88F),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamMemberMiniCard(String name, String role, String branch) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFFFEBE4),
            child: Text(name.isNotEmpty ? name[0] : 'M', style: const TextStyle(color: Color(0xFFF7931A), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191C32)), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(branch, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(role, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF7931A))),
        ],
      ),
    );
  }
}

