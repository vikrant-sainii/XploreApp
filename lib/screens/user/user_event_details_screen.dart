import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/event/event_bloc.dart';
import '../../models/club_model.dart';
import '../../models/event_model.dart';
import '../../models/participation_model.dart';
import '../../models/user_model.dart';
import '../../services/event_service.dart';
import '../../services/payment_service.dart';
import 'club_details_screen.dart';

enum EventDraft { yes, no }

class UserEventDetailsScreen extends StatefulWidget {
  final Function(int) changeindex;
  final EventDraft preview;
  final EventModel? event;

  const UserEventDetailsScreen({
    super.key,
    required this.changeindex,
    required this.preview,
    this.event,
  });

  @override
  State<UserEventDetailsScreen> createState() => _UserEventDetailsScreenState();
}

class _UserEventDetailsScreenState extends State<UserEventDetailsScreen> {
  bool _isRegistering = false;
  bool _isLoadingEvent = true;
  EventModel? _fetchedEvent;

  EventModel get _initialEvent =>
      widget.event ??
      const EventModel(
        id: '1',
        title: 'Fresher Party',
        venue: 'CSH',
        description: 'Civil Engineering Fresher\'s Welcome Party 2026.',
        imageUrl: 'assets/workshopevent.png',
        totalSeats: 0,
        registeredCount: 0,
        entryFee: 0,
        isOpenEntry: true,
      );

  EventModel get _currentEvent => _fetchedEvent ?? _initialEvent;

  @override
  void initState() {
    super.initState();
    _loadFullEvent();
  }

  Future<void> _loadFullEvent() async {
    final initial = _initialEvent;
    if (initial.id.isEmpty || initial.id == '1') {
      if (mounted) setState(() => _isLoadingEvent = false);
      return;
    }
    try {
      final fullEvent = await EventService().getEventById(initial.id);
      if (mounted) {
        setState(() {
          _fetchedEvent = fullEvent;
          _isLoadingEvent = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingEvent = false);
      }
    }
  }

  Future<void> _launchSocialUrl(String urlString) async {
    if (urlString.trim().isEmpty) return;
    String formattedUrl = urlString.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final Uri uri = Uri.parse(formattedUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open link: $formattedUrl"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _handleRegister() async {
    final event = _currentEvent;
    if (event.isOpenEntry) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This event is open entry (walk-in) and does not require registration."),
          backgroundColor: Color(0xFF5FC88F),
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    UserModel? user;
    String? currentUserId;
    if (authState is Authenticated) {
      user = authState.user;
      currentUserId = user.id;
    }

    if (event.customFields.isNotEmpty || event.requiredFields.isNotEmpty) {
      _showRegistrationFormModal(event, user);
      return;
    }

    if (event.isPaid) {
      if (currentUserId == null || currentUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to register for paid events"), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isRegistering = true);
      try {
        final paymentService = PaymentService();
        final order = await paymentService.createOrder(
          eventId: event.id,
          studentId: currentUserId,
        );

        final verifyRes = await paymentService.verifyPayment(
          orderId: order.orderId,
          paymentId: "pay_sim_${DateTime.now().millisecondsSinceEpoch}",
          signature: "sim_sig_${DateTime.now().millisecondsSinceEpoch}",
          eventId: event.id,
          studentId: currentUserId,
        );

        if (mounted) {
          setState(() => _isRegistering = false);
          context.read<EventBloc>().add(FetchAllEvents(userId: currentUserId));
          _showSuccessTicketDialog(event, verifyRes['registration']?['id']);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isRegistering = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment failed: $e"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      context.read<EventBloc>().add(RegisterEventRequested(event.id));
    }
  }

  void _showRegistrationFormModal(EventModel event, UserModel? user) {
    final List<Map<String, dynamic>> customFieldItems = [];
    if (event.customFields.isNotEmpty) {
      for (var f in event.customFields) {
        if (f is Map) {
          customFieldItems.add(Map<String, dynamic>.from(f));
        } else if (f != null && f.toString().isNotEmpty) {
          customFieldItems.add({'label': f.toString(), 'required': true});
        }
      }
    }
    if (customFieldItems.isEmpty && event.requiredFields.isNotEmpty) {
      for (var f in event.requiredFields) {
        if (f.isNotEmpty) {
          customFieldItems.add({'label': f, 'required': true});
        }
      }
    }

    final Map<String, TextEditingController> fieldControllers = {};
    for (var item in customFieldItems) {
      final label = item['label']?.toString() ?? item['question']?.toString() ?? item['title']?.toString() ?? 'Field';
      fieldControllers[label] = TextEditingController();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1F2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7931A).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.assignment_outlined, color: Color(0xFFF7931A), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Registration Form",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Fill in the details to complete your registration",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Section 1: Auto-filled profile
                    const Text(
                      "YOUR PROFILE (AUTO-FILLED)",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _profileInfoCard("NAME", user?.name.isNotEmpty == true ? user!.name : "AJEET YADAV"),
                        _profileInfoCard("ROLL NO", user?.rollNo?.isNotEmpty == true ? user!.rollNo! : "24102006"),
                        _profileInfoCard("EMAIL", user?.email.isNotEmpty == true ? user!.email : "student@nitj.ac.in"),
                        _profileInfoCard("BRANCH", user?.branch?.isNotEmpty == true ? user!.branch! : "CE"),
                        _profileInfoCard("YEAR", user?.year != null ? "${user!.year} Year" : "3rd Year"),
                        _profileInfoCard("PROGRAM", user?.program?.isNotEmpty == true ? user!.program! : "BTECH"),
                      ],
                    ),

                    // Section 2: Custom fields
                    if (customFieldItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      const Text(
                        "ADDITIONAL INFORMATION",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 12),
                      ...customFieldItems.map((item) {
                        final String label = item['label']?.toString() ?? item['question']?.toString() ?? item['title']?.toString() ?? 'Field';
                        final bool isReq = item['required'] == true || item['isRequired'] == true || true;
                        final controller = fieldControllers[label];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: label,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                                  children: [
                                    if (isReq)
                                      const TextSpan(text: " *", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: label.toLowerCase().contains('link') || label.toLowerCase().contains('drive') ? "https://..." : "Your answer...",
                                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                  filled: true,
                                  fillColor: const Color(0xFF27293D),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(modalCtx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final Map<String, dynamic> responses = {};
                              for (var item in customFieldItems) {
                                final String label = item['label']?.toString() ?? item['question']?.toString() ?? item['title']?.toString() ?? 'Field';
                                final bool isReq = item['required'] == true || item['isRequired'] == true || true;
                                final val = fieldControllers[label]?.text.trim() ?? '';

                                if (isReq && val.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("\"$label\" is required. Please provide a response."),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }
                                if (val.isNotEmpty) {
                                  responses[label] = val;
                                }
                              }

                              Navigator.pop(modalCtx);
                              context.read<EventBloc>().add(
                                    RegisterEventRequested(event.id, formResponses: responses),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7931A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("Register", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF27293D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showSuccessTicketDialog(EventModel event, String? ticketCode) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF5FC88F), size: 55),
            const SizedBox(height: 12),
            const Text(
              "Registration Confirmed!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "You are registered for ${event.title}.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code, size: 100, color: Color(0xFF191C32)),
            ),
            const SizedBox(height: 8),
            Text(
              ticketCode ?? "QR-${event.id.substring(0, event.id.length > 6 ? 6 : event.id.length)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<EventBloc>().add(FetchAllEvents(userId: currentUserId));
                widget.changeindex(1);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF191C32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("View in My Tickets", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomableImageDialog(BuildContext context, String imagePath, bool isNetwork) {
    final bool isFile = !isNetwork && (imagePath.startsWith('/') || imagePath.startsWith('file://') || File(imagePath.replaceFirst('file://', '')).existsSync());

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: isNetwork
                    ? Image.network(imagePath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset('assets/workshopevent.png'))
                    : (isFile
                        ? Image.file(File(imagePath.replaceFirst('file://', '')), fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset('assets/workshopevent.png'))
                        : Image.asset(imagePath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset('assets/workshopevent.png'))),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePosterCard(BuildContext context, EventModel event) {
    final String imagePath = event.imageLocation;
    final bool isNetwork = imagePath.startsWith('http');
    final bool isFile = !isNetwork && (imagePath.startsWith('/') || imagePath.startsWith('file://') || File(imagePath.replaceFirst('file://', '')).existsSync());

    return GestureDetector(
      onTap: () => _showZoomableImageDialog(context, imagePath, isNetwork),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                height: 210,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF191C32)),
                child: isNetwork
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset('assets/workshopevent.png', fit: BoxFit.cover),
                      )
                    : (isFile
                        ? Image.file(
                            File(imagePath.replaceFirst('file://', '')),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset('assets/workshopevent.png', fit: BoxFit.cover),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset('assets/workshopevent.png', fit: BoxFit.cover),
                          )),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text("Tap to zoom poster 🔍", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = _currentEvent;
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : null;

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventRegistrationSuccess) {
          context.read<EventBloc>().add(FetchAllEvents(userId: currentUserId));
          _showSuccessTicketDialog(event, state.qrCode);
        } else if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          leadingWidth: 60,
          backgroundColor: const Color(0xFFFF9AB2),
          leading: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                iconSize: 24,
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          title: widget.preview == EventDraft.yes
              ? const Text(
                  "EVENT PREVIEW",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                )
              : null,
        ),
        body: BlocBuilder<EventBloc, EventState>(
          builder: (context, eventState) {
            bool isAlreadyRegistered = event.isRegistered;
            String? existingQrCode;

            if (eventState is EventsLoaded) {
              isAlreadyRegistered = isAlreadyRegistered ||
                  eventState.registeredEvents.any((e) => e.id == event.id);

              final participation = eventState.userParticipations
                  .cast<ParticipationModel?>()
                  .firstWhere(
                    (p) => p?.event?.id == event.id || p?.eventId == event.id,
                    orElse: () => null,
                  );
              if (participation != null && participation.qrCode.isNotEmpty) {
                existingQrCode = participation.qrCode;
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final width = constraints.maxWidth;
                return Container(
                  color: const Color(0xFFFF9AB2),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, left: 24, right: 8),
                          child: SizedBox(
                            width: width * 0.48,
                            height: height * 0.18,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                event.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Image.asset(
                          "assets/pillar.png",
                          height: height * 0.25,
                          width: width * 0.5,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: height * 0.2,
                          left: width * 0.02,
                          right: width * 0.02,
                        ),
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: const Color(0xFFF7F7FA),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 20),
                          child: ListView(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        letterSpacing: -0.5,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Color(0xFF191C32),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBE4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${event.formattedDate} • ${event.formattedTime}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFF7931A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.venue != null ? "Venue : ${event.venue}" : "Venue TBA",
                                style: const TextStyle(
                                  color: Color(0xFF9395A4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              // Review Status Header Badge (if pending or in review)
                              _buildReviewStatusHeader(event),

                              // Badges Row
                              Row(
                                children: [
                                  _buildBadge(
                                    icon: Icons.currency_rupee,
                                    label: event.entryFee > 0 ? "₹${event.entryFee}" : "FREE",
                                    color: const Color(0xFF5FC88F),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildBadge(
                                    icon: Icons.people_outline,
                                    label: event.totalSeats > 0
                                        ? "${event.registeredCount}/${event.totalSeats} Seats"
                                        : "${event.registeredCount} Registered",
                                    color: const Color(0xFF191C32),
                                  ),
                                ],
                              ),

                              // Interactive Event Poster Image Card
                              _buildInteractivePosterCard(context, event),

                              const SizedBox(height: 12),

                              // Description Header
                              const Text(
                                "Description",
                                style: TextStyle(
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF191C32),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Rich Markdown Description Renderer
                              if (_isLoadingEvent)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(color: Color(0xFFF7931A)),
                                  ),
                                )
                              else
                                RichMarkdownViewer(
                                  content: event.description ?? 'Join us for this exciting campus event organized by student clubs.',
                                ),

                              const SizedBox(height: 16),

                              // Rules & Guidelines Section (if present)
                              if (event.rules != null && event.rules!.trim().isNotEmpty) ...[
                                const Text(
                                  "Rules & Guidelines",
                                  style: TextStyle(
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF191C32),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichMarkdownViewer(content: event.rules!),
                                const SizedBox(height: 16),
                              ],

                              // Full Event Specifications Card (for Faculty Review & Preview)
                              _buildEventSpecificationsCard(event),

                              const SizedBox(height: 16),

                              // Payment Specifications Card (if paid)
                              if (event.isPaid) ...[
                                _buildPaymentSpecificationsCard(event),
                                const SizedBox(height: 16),
                              ],

                              // Custom Form Fields Requested Card
                              if (event.customFields.isNotEmpty || event.requiredFields.isNotEmpty) ...[
                                _buildCustomFieldsCard(event),
                                const SizedBox(height: 16),
                              ],

                              // Sponsors Card
                              if (event.sponsors.isNotEmpty) ...[
                                _buildSponsorsCard(event),
                                const SizedBox(height: 16),
                              ],

                              // Media Links Card
                              if (event.media.isNotEmpty) ...[
                                _buildMediaCard(event),
                                const SizedBox(height: 16),
                              ],

                              // Organized By & Social Connect Card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: () {
                                               final clubId = event.clubId ?? (event.club is Map ? (event.club!['id']?.toString() ?? event.club!['_id']?.toString()) : null) ?? '1';
                                               final clubName = event.clubName.isNotEmpty && event.clubName != 'College Club' ? event.clubName : 'Kalakaar';
                                               final clubObj = ClubModel(
                                                 id: clubId,
                                                 name: clubName,
                                                 slug: clubName.toLowerCase().replaceAll(' ', '-'),
                                                 description: (event.club is Map) ? event.club!['description']?.toString() : 'Official Student Club',
                                               );
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(
                                                   builder: (_) => ClubDetailsScreen(club: clubObj),
                                                 ),
                                               );
                                             },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: Color(0xFFFFEBE4),
                                                    child: Icon(Icons.groups, color: Color(0xFFF7931A), size: 20),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text("ORGANIZED BY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                event.clubName.isNotEmpty ? event.clubName : "Kalakaar",
                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191C32)),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 4),
                                                            const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFF7931A)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F), size: 18),
                                          tooltip: "Open Instagram",
                                          onPressed: () {
                                            final instaUrl = event.instagramUrl ??
                                                "https://instagram.com/${event.clubName.toLowerCase().replaceAll(' ', '')}";
                                            _launchSocialUrl(instaUrl);
                                          },
                                        ),
                                        IconButton(
                                          icon: const FaIcon(FontAwesomeIcons.linkedin, color: Color(0xFF0A66C2), size: 18),
                                          tooltip: "Open LinkedIn",
                                          onPressed: () {
                                            final linkedinUrl = event.linkedinUrl ??
                                                "https://linkedin.com/search/results/all/?keywords=${Uri.encodeComponent(event.clubName)}";
                                            _launchSocialUrl(linkedinUrl);
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),

                                    // Dynamic Social Share Row (WhatsApp, X, Copy / Portfolio Link)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                          icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 20),
                                          tooltip: "Share on WhatsApp",
                                          onPressed: () {
                                            final shareMsg = "Check out ${event.title} organized by ${event.clubName} on CampusNode! https://campusnode-server.onrender.com/events/${event.id}";
                                            final whatsappUrl = (event.whatsappNumber != null && event.whatsappNumber!.isNotEmpty)
                                                ? "https://api.whatsapp.com/send?phone=${event.whatsappNumber}&text=${Uri.encodeComponent(shareMsg)}"
                                                : "https://api.whatsapp.com/send?text=${Uri.encodeComponent(shareMsg)}";
                                            _launchSocialUrl(whatsappUrl);
                                          },
                                        ),
                                        IconButton(
                                          icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: 20),
                                          tooltip: "Share on X",
                                          onPressed: () {
                                            final twitterUrl = event.twitterUrl ??
                                                "https://twitter.com/intent/tweet?text=${Uri.encodeComponent('Check out ${event.title} organized by ${event.clubName} on CampusNode! https://campusnode-server.onrender.com/events/${event.id}')}";
                                            _launchSocialUrl(twitterUrl);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            event.portfolioUrl != null ? Icons.language : Icons.link,
                                            color: const Color(0xFF191C32),
                                            size: 20,
                                          ),
                                          tooltip: event.portfolioUrl != null ? "Open Website" : "Copy Link",
                                          onPressed: () {
                                            if (event.portfolioUrl != null && event.portfolioUrl!.isNotEmpty) {
                                              _launchSocialUrl(event.portfolioUrl!);
                                            } else {
                                              Clipboard.setData(ClipboardData(text: "https://campusnode-server.onrender.com/events/${event.id}"));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Event link copied to clipboard!"), backgroundColor: Colors.green),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Register / View Pass / Faculty Approval Action Bar
                              _buildBottomActionBar(event, isAlreadyRegistered, existingQrCode),

                              // Dynamic Frequently Asked Questions (4 Accordions)
                              _buildDynamicFaqSection(event),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewStatusHeader(EventModel event) {
    final status = event.reviewStatus.toUpperCase();
    final bool isPending = status == 'PENDING';
    final bool isRejected = status == 'REJECTED';

    final Color color = isPending
        ? const Color(0xFFF7931A)
        : isRejected
            ? Colors.redAccent
            : const Color(0xFF5FC88F);
    final String label = isPending
        ? "PENDING FACULTY REVIEW"
        : isRejected
            ? "PROPOSAL REJECTED"
            : "PUBLISHED EVENT";

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPending
                    ? Icons.hourglass_top_rounded
                    : isRejected
                        ? Icons.cancel_outlined
                        : Icons.check_circle_outline,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (isRejected && event.reviewComment != null && event.reviewComment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Faculty Rejection Reason: ${event.reviewComment}",
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventSpecificationsCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: const [
              Icon(Icons.tune, color: Color(0xFFF7931A), size: 20),
              SizedBox(width: 8),
              Text(
                "REGISTRATION & RESTRICTIONS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF191C32), letterSpacing: 0.8),
              ),
            ],
          ),
          const Divider(height: 20),
          _specRow("Registration Mode", event.isTeamRegistration ? "Team (${event.minTeamSize}-${event.maxTeamSize} members)" : "Individual"),
          if (event.registrationDeadline != null)
            _specRow("Deadline", "${event.registrationDeadline!.day}/${event.registrationDeadline!.month}/${event.registrationDeadline!.year}"),
          _specRow("NITJ / College Only", event.onlyCollegeStudents ? "Yes" : "No"),
          _specRow("Allowed Programs", event.allowedPrograms.isNotEmpty ? event.allowedPrograms.join(', ') : "All Programs"),
          _specRow("Allowed Years", event.allowedYears.isNotEmpty ? event.allowedYears.join(', ') : "All Years"),
          _specRow("Allowed Branches", event.allowedBranches.isNotEmpty ? event.allowedBranches.join(', ') : "All Branches"),
          _specRow("External Participants", event.allowExternalParticipants ? "Allowed" : "Not Allowed"),
          _specRow("Show Winners on Card", event.showWinner ? "Enabled" : "Disabled"),
        ],
      ),
    );
  }

  Widget _buildPaymentSpecificationsCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: const [
              Icon(Icons.payment, color: Color(0xFF5FC88F), size: 20),
              SizedBox(width: 8),
              Text(
                "PAYMENT DETAILS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF191C32), letterSpacing: 0.8),
              ),
            ],
          ),
          const Divider(height: 20),
          _specRow("Entry Fee", "₹${event.entryFee}"),
          _specRow("Payment Method", event.paymentMethod.replaceAll('_', ' ').toUpperCase()),
          if (event.upiId != null && event.upiId!.isNotEmpty) ...[
            _specRow("UPI ID", event.upiId!),
            if (event.accountHolderName != null && event.accountHolderName!.isNotEmpty)
              _specRow("Account Holder", event.accountHolderName!),
          ],
          if (event.collegePaymentUrl != null && event.collegePaymentUrl!.isNotEmpty)
            _specRow("College Portal URL", event.collegePaymentUrl!),
          if (event.paymentInstructions != null && event.paymentInstructions!.isNotEmpty)
            _specRow("Instructions", event.paymentInstructions!),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsCard(EventModel event) {
    final fields = event.customFields.isNotEmpty ? event.customFields : event.requiredFields;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.quiz_outlined, color: Color(0xFF191C32), size: 20),
              SizedBox(width: 8),
              Text(
                "CUSTOM REGISTRATION FORM FIELDS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF191C32), letterSpacing: 0.8),
              ),
            ],
          ),
          const Divider(height: 20),
          ...fields.map((f) {
            String label = 'Field';
            String type = 'text';
            bool req = true;
            if (f is Map) {
              label = f['label']?.toString() ?? 'Question';
              type = f['type']?.toString() ?? 'text';
              req = f['required'] == true;
            } else {
              label = f.toString();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 18, color: Color(0xFFF7931A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text("$label ($type)", style: const TextStyle(fontSize: 13, color: Color(0xFF191C32), fontWeight: FontWeight.w500)),
                  ),
                  if (req)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                      child: const Text("Required", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSponsorsCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium, color: Color(0xFFF7931A), size: 20),
              SizedBox(width: 8),
              Text(
                "EVENT SPONSORS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF191C32), letterSpacing: 0.8),
              ),
            ],
          ),
          const Divider(height: 20),
          ...event.sponsors.map((s) {
            final name = s['name']?.toString() ?? 'Sponsor';
            final web = s['websiteUrl']?.toString();
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBE4),
                child: Icon(Icons.business, color: Color(0xFFF7931A), size: 20),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: web != null && web.isNotEmpty ? Text(web, style: const TextStyle(color: Colors.blue, fontSize: 12)) : null,
              onTap: web != null && web.isNotEmpty ? () => _launchSocialUrl(web) : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMediaCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.perm_media, color: Color(0xFF191C32), size: 20),
              SizedBox(width: 8),
              Text(
                "MEDIA LINKS & PROMOS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF191C32), letterSpacing: 0.8),
              ),
            ],
          ),
          const Divider(height: 20),
          ...event.media.map((m) {
            final title = m['title']?.toString() ?? 'Media Link';
            final url = m['url']?.toString() ?? '';
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link, color: Color(0xFF5FC88F)),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(url, style: const TextStyle(color: Colors.blue, fontSize: 12)),
              onTap: url.isNotEmpty ? () => _launchSocialUrl(url) : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: Color(0xFF191C32), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSubmittingDraft = false;

  Future<void> _handleConfirmAndSubmitDraft(BuildContext context, EventModel event) async {
    setState(() => _isSubmittingDraft = true);
    try {
      final authState = context.read<AuthBloc>().state;
      String? clubId;
      if (authState is Authenticated) {
        clubId = authState.user.clubId;
      }

      final eventData = event.toCreateJson();
      if (clubId != null && clubId.isNotEmpty && clubId != '1') {
        eventData['clubId'] = clubId;
      }

      final imageUrlStr = event.imageUrl ?? '';
      if (imageUrlStr.isNotEmpty && !imageUrlStr.startsWith('http')) {
        final uploadedUrl = await EventService().uploadPoster(imageUrlStr);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          eventData['imageUrl'] = uploadedUrl;
        }
      }

      await EventService().createEvent(eventData);

      if (context.mounted) {
        setState(() => _isSubmittingDraft = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Event proposal submitted for Faculty Review! 🚀"),
            backgroundColor: Color(0xFF5FC88F),
          ),
        );
        widget.changeindex(3);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isSubmittingDraft = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit event: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildBottomActionBar(EventModel event, bool isAlreadyRegistered, String? existingQrCode) {
    final authState = context.read<AuthBloc>().state;
    String? userRole;
    if (authState is Authenticated) {
      userRole = authState.user.role.toLowerCase();
    }
    final bool isFacultyOrAdmin = userRole == 'facultycoordinator' || userRole == 'admin' || userRole == 'faculty';
    final bool isDraft = event.id.startsWith('draft-') || (widget.preview == EventDraft.yes && !isFacultyOrAdmin);

    if (isDraft) {
      return ElevatedButton.icon(
        onPressed: _isSubmittingDraft ? null : () => _handleConfirmAndSubmitDraft(context, event),
        icon: _isSubmittingDraft
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.rocket_launch, color: Colors.white),
        label: Text(
          _isSubmittingDraft ? "SUBMITTING PROPOSAL..." : "CONFIRM & SUBMIT FOR FACULTY REVIEW 🚀",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5FC88F),
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    }

    final bool isPending = event.reviewStatus.toUpperCase() == 'PENDING';

    if (isFacultyOrAdmin && isPending) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleApproveEvent(context, event),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text(
                    "APPROVE EVENT 🚀",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5FC88F),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRejectionDialog(context, event),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text(
                    "REJECT PROPOSAL ❌",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (event.reviewStatus.toUpperCase() == 'REJECTED') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Text(
          "EVENT PROPOSAL REJECTED ❌",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    }

    if (event.isOpenEntry) {
      return ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This event is open entry (walk-in) and does not require registration."),
              backgroundColor: Color(0xFF5FC88F),
            ),
          );
        },
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text(
          "OPEN ENTRY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5FC88F),
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      );
    }

    if (isAlreadyRegistered) {
      return ElevatedButton.icon(
        onPressed: () => _showSuccessTicketDialog(event, existingQrCode),
        icon: const Icon(Icons.confirmation_number, color: Colors.white),
        label: const Text(
          "VIEW ENTRY PASS 🎟",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5FC88F),
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _isRegistering ? null : _handleRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF191C32),
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: _isRegistering
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              event.isTeamRegistration
                  ? (event.isPaid ? "REGISTER AS TEAM (PAY ₹${event.entryFee})" : "REGISTER AS TEAM (FREE)")
                  : (event.isPaid ? "REGISTER INDIVIDUAL (PAY ₹${event.entryFee})" : "REGISTER INDIVIDUAL (FREE)"),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
    );
  }

  void _showRejectionDialog(BuildContext context, EventModel event) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("Reject Event Proposal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Provide feedback to the club organizer explaining why this proposal is rejected:",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter rejection reason...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final comment = commentController.text.trim();
              Navigator.pop(ctx);
              try {
                await EventService().reviewEvent(event.id, status: 'REJECTED', comment: comment);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Event proposal rejected with feedback."), backgroundColor: Colors.orange),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to reject event: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("REJECT PROPOSAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleApproveEvent(BuildContext context, EventModel event) async {
    try {
      await EventService().reviewEvent(event.id, status: 'PUBLISHED');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Event Approved & Published to Campus! 🚀"),
            backgroundColor: Color(0xFF5FC88F),
          ),
        );
        widget.changeindex(3);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to approve event: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDynamicFaqSection(EventModel event) {
    final String dateText = event.formattedDateWithTime;
    final String endText = event.endTime != null ? ' and ends on ${event.formattedEndDateWithTime}' : '';
    final String venueText = event.venue ?? 'CSH';

    final q1Answer = "The event starts on $dateText$endText. It will be held at $venueText.";

    final q2Answer = event.isOpenEntry
        ? "Registration Type: OPEN ENTRY (Walk-In). There is no separate registration required — simply walk in on the event day! Entry is Completely Free."
        : event.isTeamRegistration
            ? "Registration Type: TEAM REGISTRATION (Team size: ${event.minTeamSize} to ${event.maxTeamSize} members). Entry fee: ${event.isPaid ? '₹${event.entryFee}' : 'Free'}. Registrations remain open until seats are full."
            : "Registration Type: INDIVIDUAL (1 Person). Entry fee: ${event.isPaid ? '₹${event.entryFee}' : 'Free'}. Registrations remain open until seats are full.";

    final q3Answer = "This event has ${event.totalSeats > 0 ? '${event.totalSeats} Seats' : 'Unlimited Seats'}. Eligibility is open to programs: ${event.allowedPrograms.isNotEmpty ? event.allowedPrograms.join(', ') : 'BTECH'}. ${event.providesCertificate ? 'Certificates will be provided to participants.' : 'No certificates will be provided for this event.'}";

    final q4Answer = "This event is organized centrally by ${event.clubName.isNotEmpty ? event.clubName : 'the Office of DSW (Dean Student Welfare)'}.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "FREQUENTLY ASKED QUESTIONS",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
        const SizedBox(height: 10),
        _faqAccordion("When and where is the event scheduled?", q1Answer),
        _faqAccordion("What are the registration details, deadline, and entry fees?", q2Answer),
        _faqAccordion("What is the seat capacity, program eligibility, and are certificates provided?", q3Answer),
        _faqAccordion("Who is organizing this event and can I cancel my ticket?", q4Answer),
      ],
    );
  }

  Widget _faqAccordion(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191C32)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: const TextStyle(color: Color(0xFF6E7191), fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class RichMarkdownViewer extends StatelessWidget {
  final String content;

  const RichMarkdownViewer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final cleanContent = content
        .replaceAll(RegExp(r'<p>\s*</p>'), '')
        .replaceAll(RegExp(r'</?p>'), '')
        .replaceAll(RegExp(r'</?br/?>'), '\n')
        .replaceAll(RegExp(r'</?div[^>]*>'), '');

    return MarkdownBody(
      data: cleanContent,
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
  }
}
