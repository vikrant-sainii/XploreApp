import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/config/string_utils.dart';
import 'package:xplore_app/models/event_model.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/components/tag_pill.dart';
import 'package:xplore_app/components/highlight_card.dart';
import 'package:xplore_app/components/faq_accordion_tile.dart';

enum EventDraft { yes, no }

class UserEventDetailsScreen extends StatefulWidget {
  final EventModel? event;
  final Function(int)? changeindex;
  final EventDraft preview;

  const UserEventDetailsScreen({
    super.key,
    this.event,
    this.changeindex,
    required this.preview,
  });

  @override
  State<UserEventDetailsScreen> createState() => _UserEventDetailsScreenState();
}

class _UserEventDetailsScreenState extends State<UserEventDetailsScreen> {
  // Local state flags
  bool _isBookmarked = false;
  String _selectedReminderTime = "1 hour before";

  // Track open states for FAQs accordion
  final Map<int, bool> _faqExpandedState = {
    0: false,
    1: false,
    2: false,
    3: false,
  };

  String _formatFullDate(DateTime? dateTime) {
    if (dateTime == null) return "Thursday, 20 August 2026";
    try {
      return DateFormat('EEEE, d MMMM yyyy').format(dateTime);
    } catch (_) {
      return "Thursday, 20 August 2026";
    }
  }

  String _formatShortDate(DateTime? dateTime) {
    if (dateTime == null) return "20 Aug 2026";
    try {
      return DateFormat('d MMM yyyy').format(dateTime);
    } catch (_) {
      return "20 Aug 2026";
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "18:00";
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return "18:00";
    }
  }

  String _calculateDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "2h";
    final diff = end.difference(start);
    if (diff.inHours >= 1) {
      final mins = diff.inMinutes.remainder(60);
      if (mins > 0) {
        return "${diff.inHours}h ${mins}m";
      }
      return "${diff.inHours}h";
    }
    return "${diff.inMinutes}m";
  }

  void _handleRegistrationAction(BuildContext context, UserModel? user) {
    if (widget.event == null) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to register for events.")),
      );
      return;
    }

    final isRegistered = widget.event!.isRegistered;
    if (isRegistered) {
      // Show confirmation dialog before deregistering
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: const Text("Confirm Deregistration", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to cancel your ticket for \"${widget.event!.title}\"?",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Keep Ticket", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<EventBloc>().add(DeregisterFromEvent(
                      eventId: widget.event!.id,
                      studentId: user.id,
                    ));
              },
              child: const Text("Confirm Deregister", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      context.read<EventBloc>().add(RegisterForEvent(
            eventId: widget.event!.id,
          ));
    }
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getShareUrl() {
    final slug = widget.event?.slug.isNotEmpty == true
        ? widget.event!.slug
        : 'ladc-debate-league-2026';
    return "https://campusnode.edu/events/$slug";
  }

  String _getShareMessage(String title, String clubName) {
    return "🏆 Join me at \"$title\" organized by $clubName on CAMPUSNODE!\n\nCheck out the details and get tickets here: ${_getShareUrl()}";
  }

  void _showOptionsMenu(String title, String clubName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.primary,
              ),
              title: Text(
                _isBookmarked ? "Remove Bookmark" : "Save / Bookmark Event",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _isBookmarked = !_isBookmarked;
                });
                _showActionFeedback(
                  _isBookmarked ? "Event saved to your bookmarks!" : "Event removed from bookmarks.",
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.white),
              title: const Text("Add to Calendar", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showCalendarModal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.white),
              title: const Text("Copy Event Link", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: _getShareUrl()));
                _showActionFeedback("Event link copied to clipboard!");
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
              title: const Text("Report Event", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _showReportDialog(title);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final options = ["At event start", "15 minutes before", "1 hour before", "1 day before"];
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "SET CALENDAR REMINDER",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Choose when you'd like to receive a notification alert:",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (opt) => RadioListTile<String>(
                    title: Text(opt, style: const TextStyle(color: Colors.white)),
                    activeColor: AppColors.primary,
                    value: opt,
                    groupValue: _selectedReminderTime,
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          _selectedReminderTime = val;
                        });
                        setState(() {
                          _selectedReminderTime = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showActionFeedback("Reminder scheduled for $_selectedReminderTime!");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("SAVE REMINDER", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReportDialog(String title) {
    String selectedReason = "Inappropriate Content";
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final reasons = ["Inappropriate Content", "Spam / Misleading", "False Information", "Other"];
          return AlertDialog(
            backgroundColor: AppColors.cardColor,
            title: const Text("Report Event", style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reason for reporting \"$title\":", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  ...reasons.map((r) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(r, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    value: r,
                    groupValue: selectedReason,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedReason = v);
                    },
                  )),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Additional details (optional)...",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showActionFeedback("Thank you! Your report has been submitted for review.");
                },
                child: const Text("Submit Report"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSocialConnectModal(String clubName, String platform) {
    final handle = "@${clubName.toLowerCase().replaceAll(' ', '_')}_official";
    final url = platform.toLowerCase() == "instagram"
        ? "https://instagram.com/${clubName.toLowerCase()}"
        : "https://linkedin.com/company/${clubName.toLowerCase()}";

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              platform.toLowerCase() == "instagram" ? FontAwesomeIcons.instagram : FontAwesomeIcons.linkedinIn,
              size: 44,
              color: platform.toLowerCase() == "instagram" ? Colors.purpleAccent : Colors.blueAccent,
            ),
            const SizedBox(height: 12),
            Text(
              "Connect with $clubName on ${platform.toUpperCase()}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              handle,
              style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                    label: const Text("Copy Link", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: url));
                      _showActionFeedback("Profile link copied to clipboard!");
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                    label: const Text("Visit Profile", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showActionFeedback("Opening $platform profile for $clubName...");
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareModal(String title, String clubName) {
    final message = _getShareMessage(title, clubName);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "SHARE EVENT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareModalOption(
                  icon: FontAwesomeIcons.whatsapp,
                  color: const Color(0xFF22C55E),
                  label: "WhatsApp",
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: message));
                    _showActionFeedback("Invite text copied! Opening WhatsApp...");
                  },
                ),
                _buildShareModalOption(
                  icon: FontAwesomeIcons.xTwitter,
                  color: Colors.white,
                  label: "X (Twitter)",
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: message));
                    _showActionFeedback("Tweet text copied to clipboard!");
                  },
                ),
                _buildShareModalOption(
                  icon: Icons.copy,
                  color: AppColors.primary,
                  label: "Copy Text",
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: message));
                    _showActionFeedback("Event invite text copied!");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareModalOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _inferClubNameFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('gdgc') || lower.contains('gdsc') || lower.contains('google')) return 'GDGC';
    if (lower.contains('ladc') || lower.contains('debate')) return 'LADC';
    if (lower.contains('octave') || lower.contains('music')) return 'Octave';
    if (lower.contains('rtp') || lower.contains('photo')) return 'RTP';
    if (lower.contains('dramatics') || lower.contains('theatre')) return 'Dramatics';
    if (lower.contains('fine arts') || lower.contains('art')) return 'Fine Arts';
    return 'Campus Club';
  }

  String _inferCategoryFromTitleAndDescription(String title, String desc) {
    final combined = '$title $desc'.toLowerCase();
    if (combined.contains('debate') || combined.contains('literary') || combined.contains('speech') || combined.contains('ladc')) {
      return 'LITERATURE';
    }
    if (combined.contains('code') || combined.contains('hackathon') || combined.contains('gdgc') || combined.contains('workshop') || combined.contains('tech')) {
      return 'TECHNICAL';
    }
    if (combined.contains('music') || combined.contains('dance') || combined.contains('drama') || combined.contains('singing') || combined.contains('cultural')) {
      return 'CULTURAL';
    }
    if (combined.contains('sport') || combined.contains('cricket') || combined.contains('football') || combined.contains('chess')) {
      return 'SPORTS';
    }
    return 'GENERAL';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    final ev = widget.event;
    final cleanedTitle = cleanHtmlText(ev?.title);
    final title = cleanedTitle.isNotEmpty ? cleanedTitle : "Campus Event";
    
    final cleanedVenue = cleanHtmlText(ev?.venue);
    final venue = cleanedVenue.isNotEmpty ? cleanedVenue : "Campus Venue";
    
    final cleanedDesc = cleanHtmlText(ev?.description);
    final description = cleanedDesc.isNotEmpty
        ? cleanedDesc
        : "Join us for this exciting campus event! Check back soon for more updates from the organizing club.";

    final clubNameFromEvent = (ev?.club?.name != null && ev!.club!.name.isNotEmpty)
        ? ev.club!.name
        : ((ev?.createdBy?.name != null && ev!.createdBy!.name.isNotEmpty)
            ? ev.createdBy!.name
            : "");

    final clubName = clubNameFromEvent.isNotEmpty
        ? clubNameFromEvent
        : _inferClubNameFromTitle(title);

    final clubCategoryFromEvent = (ev?.club?.category != null && ev!.club!.category!.isNotEmpty)
        ? ev.club!.category!
        : "";

    final clubCategory = clubCategoryFromEvent.isNotEmpty
        ? clubCategoryFromEvent.toUpperCase()
        : _inferCategoryFromTitleAndDescription(title, description);

    final isCentralOrganizer = ev?.organizerType?.toUpperCase() == "CENTRAL" ||
        ev?.centralOrganizer != null ||
        clubCategory.toUpperCase() == "CENTRAL" ||
        clubName.toLowerCase().contains("dsw") ||
        clubName.toLowerCase().contains("office") ||
        clubName.toLowerCase().contains("nikhil") ||
        title.toLowerCase().contains("party") ||
        title.toLowerCase().contains("freshers");

    final organizedByTitle = isCentralOrganizer
        ? "Office of DSW"
        : clubName;

    final organizedBySubtitle = isCentralOrganizer
        ? "Dean Student Welfare"
        : "$clubCategory Club";

    final registeredCount = ev?.registeredCount ?? 0;
    final viewsCount = ev?.views ?? 1;
    final isFree = (ev?.registrationFee ?? ev?.entryFee ?? 0.0) == 0.0;
    final feeText = isFree ? "Free" : "₹${ev?.registrationFee ?? ev?.entryFee}";
    final feeEntryText = isFree ? "Free Entry" : "₹${ev?.registrationFee ?? ev?.entryFee}";
    final provideCert = ev?.provideCertificate ?? true;
    final totalSeatsText = ev?.totalSeats != null && ev!.totalSeats! > 0 ? "${ev.totalSeats} Seats" : "Unlimited Seats";
    final allowedProgsText = ev?.allowedPrograms.isNotEmpty == true
        ? ev!.allowedPrograms.join(', ')
        : "All Students";

    final bannerImgPath = (ev?.imageUrl != null && ev!.imageUrl!.isNotEmpty)
        ? ev.imageUrl!
        : ((ev?.imageLocation != null && ev!.imageLocation!.isNotEmpty)
            ? ev.imageLocation!
            : "assets/workshopevent.png");

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is EventError) {
          if (state.message.contains('QR_SIGNING_PRIVATE_KEY') || state.message.contains('Backend Server Error')) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.cardColor,
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                    SizedBox(width: 8),
                    Expanded(child: Text("Backend Config Required", style: TextStyle(color: Colors.white, fontSize: 16))),
                  ],
                ),
                content: const Text(
                  "The backend server (clubsetu-backend on Render) is missing the 'QR_SIGNING_PRIVATE_KEY' environment variable.\n\nTo enable student event registrations, please set 'QR_SIGNING_PRIVATE_KEY' in your Render service environment settings.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Got it"),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          leadingWidth: 100,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      "BACK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            widget.preview == EventDraft.yes ? "EVENT PREVIEW" : "Event Details",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              iconSize: 20,
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.more_vert,
                color: _isBookmarked ? AppColors.primary : Colors.white,
              ),
              onPressed: () => _showOptionsMenu(title, clubName),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.cardColor,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(width: 12)
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Breadcrumbs Trail
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text("Home", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
                    const Text("Events", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
                    Text(
                      clubCategory.toUpperCase(),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
                    SizedBox(
                      width: 160,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner Image with UPCOMING Badge Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: bannerImgPath.startsWith('http://') || bannerImgPath.startsWith('https://')
                        ? Image.network(
                            bannerImgPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.cardColor,
                              child: const Icon(Icons.image, color: Colors.white38, size: 50),
                            ),
                          )
                        : Image.asset(
                            bannerImgPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.cardColor,
                              child: const Icon(Icons.image, color: Colors.white38, size: 50),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_filled, size: 13, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          "UPCOMING",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Tag Pills Row (COLLEGE-WIDE EVENT, OFFICE OF DSW, FREE, CERTIFICATE)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isCentralOrganizer) ...[
                  const TagPill(
                    label: "COLLEGE-WIDE EVENT",
                    icon: Icons.auto_awesome_rounded,
                    bgColor: Color(0xFF2C160B),
                    borderColor: Color(0xFFEA580C),
                    textColor: Color(0xFFEA580C),
                  ),
                  TagPill(
                    label: organizedByTitle.toUpperCase(),
                    icon: Icons.domain_rounded,
                    iconColor: const Color(0xFFEA580C),
                    bgColor: const Color(0xFF1E1E1E),
                    borderColor: const Color(0xFF383838),
                    textColor: Colors.white,
                  ),
                ] else ...[
                  TagPill(
                    label: clubCategory.toUpperCase(),
                    bgColor: const Color(0xFF2C160B),
                    borderColor: const Color(0xFFEA580C),
                    textColor: const Color(0xFFEA580C),
                  ),
                  TagPill(
                    label: clubName.toUpperCase(),
                    bgColor: const Color(0xFF1E1E1E),
                    borderColor: const Color(0xFF383838),
                    textColor: Colors.white,
                  ),
                ],
                TagPill(
                  label: isFree ? "FREE" : "PAID",
                  bgColor: const Color(0xFF0F291B),
                  borderColor: const Color(0xFF22C55E),
                  textColor: const Color(0xFF22C55E),
                ),
                if (provideCert)
                  const TagPill(
                    label: "CERTIFICATE",
                    bgColor: Color(0xFF0E1E38),
                    borderColor: Color(0xFF3B82F6),
                    textColor: Color(0xFF3B82F6),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Event Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Sub-info Meta Metrics Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetaMetricItem(Icons.calendar_today_rounded, _formatShortDate(ev?.startTime)),
                  _buildMetaDot(),
                  _buildMetaMetricItem(Icons.location_on_rounded, venue),
                  _buildMetaDot(),
                  _buildMetaMetricItem(Icons.groups_rounded, clubName),
                  _buildMetaDot(),
                  _buildMetaMetricItem(Icons.person_rounded, "$registeredCount Registered"),
                  _buildMetaDot(),
                  _buildMetaMetricItem(Icons.remove_red_eye_rounded, "$viewsCount Views"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time Ticket Action Box (CampusNode Card)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DATE & TIME Header
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        "DATE & TIME",
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    "STARTS",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFullDate(ev?.startTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(ev?.startTime),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Location & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            venue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 18, color: Color(0xFF22C55E)),
                          const SizedBox(width: 6),
                          Text(
                            feeText,
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // GET TICKETS / REGISTER Action Button + Calendar export button
                  if (widget.preview == EventDraft.no)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleRegistrationAction(context, currentUser),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ev?.isRegistered == true
                                  ? Colors.red.shade700
                                  : Colors.white,
                              foregroundColor: ev?.isRegistered == true
                                  ? Colors.white
                                  : Colors.black,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              ev?.isRegistered == true
                                  ? "DEREGISTER FROM EVENT"
                                  : "GET TICKETS",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.5,
                                color: ev?.isRegistered == true
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _showCalendarModal,
                          borderRadius: BorderRadius.circular(26),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.border, height: 1),
                  ),

                  // ORGANIZED BY Section
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C160B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: isCentralOrganizer
                              ? const Icon(Icons.domain_rounded, color: Color(0xFFEA580C), size: 24)
                              : (ev?.club?.clubLogo != null && ev!.club!.clubLogo!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        ev.club!.clubLogo!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.groups_rounded, color: Color(0xFFEA580C), size: 22),
                                      ),
                                    )
                                  : const Icon(Icons.groups_rounded, color: Color(0xFFEA580C), size: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ORGANIZED BY",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            organizedByTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            organizedBySubtitle,
                            style: const TextStyle(
                              color: Color(0xFFEA580C),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.border, height: 1),
                  ),

                  // CONNECT WITH CLUB Section
                  Text(
                    "CONNECT WITH ${clubName.toUpperCase()}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSocialIconButton(
                        icon: FontAwesomeIcons.instagram,
                        onPressed: () => _showSocialConnectModal(clubName, "Instagram"),
                      ),
                      const SizedBox(width: 12),
                      _buildSocialIconButton(
                        icon: FontAwesomeIcons.linkedinIn,
                        onPressed: () => _showSocialConnectModal(clubName, "LinkedIn"),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.border, height: 1),
                  ),

                  // SHARE EVENT Section
                  const Text(
                    "SHARE EVENT",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildShareIconButton(
                        icon: FontAwesomeIcons.whatsapp,
                        color: const Color(0xFF22C55E),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _getShareMessage(title, clubName)));
                          _showActionFeedback("WhatsApp invite message copied to clipboard!");
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildShareIconButton(
                        icon: FontAwesomeIcons.xTwitter,
                        color: Colors.white,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _getShareMessage(title, clubName)));
                          _showActionFeedback("Tweet text copied to clipboard!");
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildShareIconButton(
                        icon: Icons.link_rounded,
                        color: Colors.white,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _getShareUrl()));
                          _showActionFeedback("Event link copied to clipboard!");
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildShareIconButton(
                        icon: Icons.share_rounded,
                        color: AppColors.primary,
                        onPressed: () => _showShareModal(title, clubName),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ABOUT THIS EVENT Section
            const Text(
              "ABOUT THIS EVENT",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // EVENT HIGHLIGHTS Grid (6 Cards)
            const Text(
              "EVENT HIGHLIGHTS",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
              children: [
                HighlightCard(
                  icon: Icons.groups_outlined,
                  label: "CAPACITY",
                  value: totalSeatsText,
                ),
                HighlightCard(
                  icon: Icons.monetization_on_outlined,
                  label: "ENTRY FEE",
                  value: feeEntryText,
                ),
                HighlightCard(
                  icon: Icons.access_time,
                  label: "DURATION",
                  value: _calculateDuration(ev?.startTime, ev?.endTime),
                ),
                HighlightCard(
                  icon: Icons.workspace_premium_outlined,
                  label: "CERTIFICATE",
                  value: provideCert ? "Provided" : "Not Provided",
                ),
                const HighlightCard(
                  icon: Icons.emoji_events_outlined,
                  label: "COMPETITION",
                  value: "Winners Announced",
                ),
                HighlightCard(
                  icon: Icons.school_outlined,
                  label: "OPEN TO",
                  value: allowedProgsText,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // FREQUENTLY ASKED QUESTIONS (FAQ Accordion)
            const Text(
              "FREQUENTLY ASKED QUESTIONS",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),

            FaqAccordionTile(
              question: "When and where is the event scheduled?",
              answer: "The event is scheduled for ${_formatFullDate(ev?.startTime)} starting at ${_formatTime(ev?.startTime)}. Location: $venue.",
              isExpanded: _faqExpandedState[0] ?? false,
              onExpansionChanged: (expanded) {
                setState(() {
                  _faqExpandedState[0] = expanded;
                });
              },
            ),
            FaqAccordionTile(
              question: "What are the registration details, deadline, and entry fees?",
              answer: "Entry is $feeEntryText. Registration mode is ${ev?.registrationType.toUpperCase() ?? 'INDIVIDUAL'}. Registration deadline is ${_formatShortDate(ev?.registrationDeadline ?? ev?.startTime)}.",
              isExpanded: _faqExpandedState[1] ?? false,
              onExpansionChanged: (expanded) {
                setState(() {
                  _faqExpandedState[1] = expanded;
                });
              },
            ),
            FaqAccordionTile(
              question: "What is the seat capacity, program eligibility, and are certificates provided?",
              answer: "Capacity: $totalSeatsText. Eligible programs: $allowedProgsText. Certificates: ${provideCert ? 'Provided to all registered participants' : 'Not provided'}.",
              isExpanded: _faqExpandedState[2] ?? false,
              onExpansionChanged: (expanded) {
                setState(() {
                  _faqExpandedState[2] = expanded;
                });
              },
            ),
            FaqAccordionTile(
              question: "Who is organizing this event and can I cancel my ticket?",
              answer: "Organized by $clubName. You can deregister directly from this screen anytime before the event starts by tapping the deregister button.",
              isExpanded: _faqExpandedState[3] ?? false,
              onExpansionChanged: (expanded) {
                setState(() {
                  _faqExpandedState[3] = expanded;
                });
              },
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaMetricItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("•", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    );
  }

  Widget _buildSocialIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildShareIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}



