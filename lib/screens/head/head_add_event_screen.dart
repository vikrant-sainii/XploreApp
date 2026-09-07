import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/models/event_model.dart';
import 'package:xplore_app/services/api_config.dart';
import 'package:xplore_app/services/event_service.dart';
import 'package:xplore_app/widgets/reusable_markdown_editor.dart';
import '../user/user_event_details_screen.dart';

class CustomFieldInput {
  TextEditingController labelController = TextEditingController();
  String type = 'Text';
  bool required = false;

  void dispose() {
    labelController.dispose();
  }
}

class SponsorInput {
  TextEditingController nameController = TextEditingController();
  TextEditingController logoUrlController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();

  void dispose() {
    nameController.dispose();
    logoUrlController.dispose();
    websiteUrlController.dispose();
  }
}

class MediaInput {
  String type = 'Video'; // 'Image', 'Video', 'Sponsor Logo', 'Document / Link'
  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  void dispose() {
    titleController.dispose();
    urlController.dispose();
  }
}

class HeadAddEventScreen extends StatefulWidget {
  final Function(int)? changeindex;
  final String? clubId;
  final String? clubName;

  const HeadAddEventScreen({
    super.key,
    this.changeindex,
    this.clubId,
    this.clubName,
  });

  @override
  State<HeadAddEventScreen> createState() => _HeadAddEventScreenState();
}

class _HeadAddEventScreenState extends State<HeadAddEventScreen> {
  int _currentStep = 1;

  // Venue Options API
  List<String> _venueOptions = [];
  bool _loadingVenues = true;
  String? _selectedVenue;

  // Step 1: Basic Details
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();

  XFile? _posterFile;
  int? _posterFileSizeBytes;

  // Step 2: Timings & Access (Initially Empty as requested)
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  DateTime? _deadlineDateTime;

  // Restrictions (Screenshot 1)
  final List<String> _selectedPrograms = ['B.Tech', 'M.Tech', 'Other'];
  bool _allowAllYears = true;
  final List<String> _selectedYears = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  bool _allowAllBranches = true;
  final List<String> _selectedBranches = ['CSE', 'ECE', 'ME', 'CE', 'EE', 'IT', 'CHE', 'ICE', 'TT', 'Other'];
  bool _allowExternalParticipants = true;

  // Step 3: Registration & Payments (Screenshots 2, 3, 4 & 5)
  String _registrationType = 'Individual Registration';
  final int _minTeamSize = 2;
  final int _maxTeamSize = 4;
  bool _unlimitedSeats = false;
  final TextEditingController _maxParticipantsController = TextEditingController(text: '100');
  String _paymentMethod = 'Free'; // 'Free', 'Manual Transaction', 'College Portal'
  final TextEditingController _entryFeeController = TextEditingController(text: '0');

  // Specific Payment Inputs (Screenshots 2 & 3)
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _customPaymentInstructionsController = TextEditingController();
  final TextEditingController _collegePaymentUrlController = TextEditingController();

  final TextEditingController _postRegistrationMsgController = TextEditingController();

  final List<String> _requiredStudentInfo = [];
  final List<CustomFieldInput> _customFields = [];

  // Step 4: Extras & Media (Screenshot 4 & 5)
  bool _displayResults = false; // "Display Results / Winners"
  bool _digitalCertificates = false;
  final List<SponsorInput> _sponsors = [];
  final List<MediaInput> _mediaLinks = [];

  @override
  void initState() {
    super.initState();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    try {
      final venues = await EventService().getVenues();
      if (mounted) {
        setState(() {
          _venueOptions = venues;
          if (_venueOptions.isNotEmpty) {
            _selectedVenue = _venueOptions.first;
            _venueController.text = _selectedVenue!;
          }
          _loadingVenues = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingVenues = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();

    _maxParticipantsController.dispose();
    _entryFeeController.dispose();
    _upiIdController.dispose();
    _accountHolderNameController.dispose();
    _customPaymentInstructionsController.dispose();
    _collegePaymentUrlController.dispose();
    _postRegistrationMsgController.dispose();
    for (var cf in _customFields) {
      cf.dispose();
    }
    for (var s in _sponsors) {
      s.dispose();
    }
    for (var m in _mediaLinks) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPosterImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file != null) {
        final length = await file.length();
        if (length > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Poster file size exceeds 5MB limit! Please choose a smaller image."),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        setState(() {
          _posterFile = file;
          _posterFileSizeBytes = length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image picking failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickDateTime({required Function(DateTime) onSelected, DateTime? initial}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: initial != null ? TimeOfDay.fromDateTime(initial) : const TimeOfDay(hour: 17, minute: 30),
      );
      if (time != null) {
        final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        onSelected(selected);
      }
    }
  }

  String _formatDateTimeDisplay(DateTime? dt) {
    if (dt == null) return "__";
    return DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
  }

  String? _resolveClubId() {
    String? resolved = widget.clubId;
    final authState = context.read<AuthBloc>().state;
    if ((resolved == null || resolved.isEmpty || resolved == '1') && authState is Authenticated) {
      final user = authState.user;
      if (user.clubId != null && user.clubId!.isNotEmpty && user.clubId != '1') {
        resolved = user.clubId;
      } else if (user.memberships.isNotEmpty) {
        final headMem = user.memberships.firstWhere(
          (m) => m.role.toUpperCase() == 'CLUB_HEAD' || m.role.toUpperCase() == 'HEAD' || m.role.toUpperCase() == 'COORDINATOR',
          orElse: () => user.memberships.first,
        );
        resolved = headMem.clubId;
      }
    }
    return resolved;
  }

  EventModel _buildDraftEventModel() {
    final String rawType = _registrationType == 'No Registration (Open / Walk-in)'
        ? 'none'
        : (_registrationType == 'Team Registration'
            ? 'team'
            : (_registrationType == 'Both (Individual & Team)' ? 'both' : 'individual'));

    final bool isOpenEntry = rawType == 'none';

    return EventModel(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Untitled Event',
      description: _descriptionController.text.trim(),
      venue: _selectedVenue ?? (_venueController.text.trim().isNotEmpty ? _venueController.text.trim() : 'CSH'),
      startTime: _startDateTime,
      endTime: _endDateTime,
      registrationDeadline: _deadlineDateTime,
      totalSeats: _unlimitedSeats ? 0 : (int.tryParse(_maxParticipantsController.text.trim()) ?? 0),
      entryFee: _paymentMethod == 'Free' ? 0.0 : (double.tryParse(_entryFeeController.text.trim()) ?? 0.0),
      imageUrl: _posterFile?.path,
      isOpenEntryFlag: isOpenEntry,
      registrationType: rawType,
      minTeamSize: _minTeamSize,
      maxTeamSize: _maxTeamSize,
      allowedPrograms: _selectedPrograms,
      allowedYears: _allowAllYears ? const ['All Years'] : _selectedYears,
      allowedBranches: _allowAllBranches ? const ['All Branches'] : _selectedBranches,
      allowExternalParticipants: _allowExternalParticipants,
      postRegistrationMessage: _postRegistrationMsgController.text.trim(),
      paymentMethod: _paymentMethod.toLowerCase().replaceAll(' ', '_'),
      upiId: _upiIdController.text.trim(),
      accountHolderName: _accountHolderNameController.text.trim(),
      paymentInstructions: _customPaymentInstructionsController.text.trim(),
      collegePaymentUrl: _collegePaymentUrlController.text.trim(),
      showWinner: _displayResults,
      reviewStatus: 'PENDING',
      clubId: _resolveClubId(),
      requiredFields: _requiredStudentInfo,
      customFields: _customFields
          .where((cf) => cf.labelController.text.trim().isNotEmpty)
          .map((cf) => {
                'label': cf.labelController.text.trim(),
                'type': cf.type,
                'required': cf.required,
              })
          .toList(),
      sponsors: _sponsors
          .where((s) => s.nameController.text.trim().isNotEmpty)
          .map((s) => {
                'name': s.nameController.text.trim(),
                'logoUrl': s.logoUrlController.text.trim(),
                'websiteUrl': s.websiteUrlController.text.trim(),
              })
          .toList(),
      media: _mediaLinks
          .where((m) => m.urlController.text.trim().isNotEmpty)
          .map((m) => {
                'type': m.type,
                'title': m.titleController.text.trim(),
                'url': m.urlController.text.trim(),
              })
          .toList(),
    );
  }

  bool _isSubmitting = false;

  void _previewEvent() {
    if (_titleController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event title must be at least 3 characters long"), backgroundColor: Colors.red),
      );
      return;
    }
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both Start Time and End Time before proceeding"), backgroundColor: Colors.red),
      );
      return;
    }
    final draft = _buildDraftEventModel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserEventDetailsScreen(
          changeindex: widget.changeindex ?? (_) {},
          preview: EventDraft.yes,
          event: draft,
        ),
      ),
    );
  }

  Future<void> _submitEvent() async {
    if (_titleController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event title must be at least 3 characters long"), backgroundColor: Colors.red),
      );
      return;
    }
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both Start Time and End Time before proceeding"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final authState = context.read<AuthBloc>().state;
      String? currentUserId;
      if (authState is Authenticated) {
        currentUserId = authState.user.id;
      }

      final clubId = _resolveClubId();
      final draft = _buildDraftEventModel();
      final eventData = draft.toCreateJson();
      if (clubId != null && clubId.isNotEmpty) {
        eventData['clubId'] = clubId;
      }
      if (currentUserId != null && currentUserId.isNotEmpty) {
        eventData['createdBy'] = currentUserId;
      }

      if (_posterFile != null) {
        final uploadedUrl = await EventService().uploadPoster(_posterFile!);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          eventData['imageUrl'] = uploadedUrl;
        } else {
          throw ApiException("Failed to upload poster image to Cloudinary.");
        }
      }

      if (mounted) {
        context.read<HeadBloc>().add(CreateClubEvent(eventData));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit event: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HeadBloc, HeadState>(
      listener: (context, state) {
        if (state is HeadActionSuccess) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF5FC88F)),
            );
            widget.changeindex?.call(3);
          }
        } else if (state is HeadError) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Submission failed: ${state.message}"), backgroundColor: Colors.red),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          leadingWidth: 60,
          backgroundColor: const Color(0xFF191C32),
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
                onPressed: () {
                  if (widget.changeindex != null) {
                    widget.changeindex!(0);
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            return Container(
              color: const Color(0xFF191C32),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 24),
                      child: const Text(
                        "Add\nEvent",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: -1,
                          fontWeight: FontWeight.w600,
                          fontSize: 37,
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
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 20),
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 120),
                        children: [
                          _buildStepperHeader(),
                          const SizedBox(height: 20),
                          if (_currentStep == 1) _buildStep1BasicDetails(),
                          if (_currentStep == 2) _buildStep2TimingsAndAccess(),
                          if (_currentStep == 3) _buildStep3RegistrationAndPay(),
                          if (_currentStep == 4) _buildStep4ExtrasAndPublishing(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stepIndicatorItem(step: 1, label: "Basic Details"),
          _stepConnector(_currentStep > 1),
          _stepIndicatorItem(step: 2, label: "Timings & Access"),
          _stepConnector(_currentStep > 2),
          _stepIndicatorItem(step: 3, label: "Registration & Pay"),
          _stepConnector(_currentStep > 3),
          _stepIndicatorItem(step: 4, label: "Extras"),
        ],
      ),
    );
  }

  Widget _stepIndicatorItem({required int step, required String label}) {
    final bool isPassed = _currentStep > step;
    final bool isCurrent = _currentStep == step;

    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isPassed
              ? const Color(0xFF5FC88F)
              : (isCurrent ? const Color(0xFFF7931A) : Colors.grey.shade300),
          child: isPassed
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  "$step",
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? const Color(0xFF191C32) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _stepConnector(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? const Color(0xFF5FC88F) : Colors.grey.shade300,
      ),
    );
  }

  // STEP 1: BASIC DETAILS
  Widget _buildStep1BasicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STEP 1: BASIC DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32))),
        const Text("Provide core event title, description, venue, and poster image.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        _buildDarkSection(
          children: [
            const Text("Event Title *", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: myInputDecor("e.g. LADC Debate 2026"),
            ),
            const SizedBox(height: 14),

            // Reusable Markdown Editor (No setState during build!)
            ReusableMarkdownEditor(
              controller: _descriptionController,
              label: "Event Description (Markdown Supported)",
              hintText: "Write comprehensive description of your event using Markdown formatting...",
            ),
            const SizedBox(height: 14),

            // Poster Upload from Phone (Max 5MB)
            const Text("Event Poster (Max 5MB)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickPosterImage,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text("Upload Poster"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7931A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _posterFile != null
                              ? "${_posterFile!.name} (${(_posterFileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB)"
                              : "No file picked (Max 5MB)",
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_posterFile != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_posterFile!.path),
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Venue API Selection Only
            const Text("Venue / Location * (Select from API)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _loadingVenues
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Color(0xFFF7931A)),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _venueOptions.contains(_selectedVenue) ? _selectedVenue : (_venueOptions.isNotEmpty ? _venueOptions.first : null),
                        isExpanded: true,
                        items: _venueOptions.map((v) {
                          return DropdownMenuItem<String>(
                            value: v,
                            child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C32))),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedVenue = val;
                              _venueController.text = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (widget.changeindex != null) {
                    widget.changeindex!(0);
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("CANCEL", style: TextStyle(color: Color(0xFF191C32), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Event title must be at least 3 characters long"), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  setState(() => _currentStep = 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("NEXT STEP ➔", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 2: TIMINGS & ACCESS (Fixed 0px Overflow & Responsive Picker Containers)
  Widget _buildStep2TimingsAndAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STEP 2: TIMINGS & ACCESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32))),
        const Text("Set event dates, start & end times, and target audience restrictions.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        _buildDarkSection(
          children: [
            // Start Time (Full Width responsive container to prevent overflow)
            Row(
              children: const [
                Text("START TIME ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickDateTime(
                initial: _startDateTime,
                onSelected: (dt) => setState(() => _startDateTime = dt),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDateTimeDisplay(_startDateTime),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _startDateTime != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // End Time
            Row(
              children: const [
                Text("END TIME ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickDateTime(
                initial: _endDateTime,
                onSelected: (dt) => setState(() => _endDateTime = dt),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDateTimeDisplay(_endDateTime),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _endDateTime != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Registration Deadline
            const Text("REGISTRATION DEADLINE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickDateTime(
                initial: _deadlineDateTime,
                onSelected: (dt) => setState(() => _deadlineDateTime = dt),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDateTimeDisplay(_deadlineDateTime),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _deadlineDateTime != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text("Optional: If left blank, registrations stay open until start time.", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const Divider(color: Colors.white24, height: 24),

            // REGISTRATION RESTRICTIONS (Screenshot 1)
            const Text("REGISTRATION RESTRICTIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const Text("Restrict event registration to specific programs, years, or branches.", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 14),

            // ALLOWED PROGRAMS *
            Row(
              children: const [
                Text("ALLOWED PROGRAMS ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ['B.Tech', 'M.Tech', 'M.Sc', 'MBA', 'Ph.D', 'Other'].map((prog) {
                final selected = _selectedPrograms.contains(prog);
                return FilterChip(
                  label: Text(prog, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                  selected: selected,
                  selectedColor: const Color(0xFFF7931A),
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedPrograms.add(prog);
                      } else {
                        _selectedPrograms.remove(prog);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // ALLOWED YEARS
            const Text("ALLOWED YEARS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            CheckboxListTile(
              activeColor: const Color(0xFFF7931A),
              contentPadding: EdgeInsets.zero,
              title: const Text("Allow All Years", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              value: _allowAllYears,
              onChanged: (val) => setState(() => _allowAllYears = val ?? true),
            ),
            const SizedBox(height: 10),

            // ALLOWED BRANCHES
            const Text("ALLOWED BRANCHES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            CheckboxListTile(
              activeColor: const Color(0xFFF7931A),
              contentPadding: EdgeInsets.zero,
              title: const Text("Allow All Branches", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              value: _allowAllBranches,
              onChanged: (val) => setState(() => _allowAllBranches = val ?? true),
            ),
            const SizedBox(height: 10),

            // EXTERNAL PARTICIPANT ACCESS
            const Text("EXTERNAL PARTICIPANT ACCESS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            CheckboxListTile(
              activeColor: const Color(0xFFF7931A),
              contentPadding: EdgeInsets.zero,
              title: const Text("Allow External Participants (Other Colleges & Universities)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text("Students from other colleges and institutions are eligible to register and participate in this event.", style: TextStyle(color: Colors.grey, fontSize: 11)),
              value: _allowExternalParticipants,
              onChanged: (val) => setState(() => _allowExternalParticipants = val ?? true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("⇽ BACK", style: TextStyle(color: Color(0xFF191C32), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_startDateTime == null || _endDateTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select Start Time and End Time before proceeding"), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  setState(() => _currentStep = 3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("NEXT STEP ➔", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: REGISTRATION & PAYMENTS (Exact Fields as Screenshots 2, 3, 4 & 5)
  Widget _buildStep3RegistrationAndPay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STEP 3: REGISTRATION & PAYMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32))),
        const Text("Configure entry type, seat capacity, payment options, and custom registration fields.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        _buildDarkSection(
          children: [
            // REGISTRATION TYPE *
            Row(
              children: const [
                Text("REGISTRATION TYPE ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF7931A), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _registrationType,
                  isExpanded: true,
                  items: [
                    'Individual Registration',
                    'Team Registration',
                    'Both (Individual & Team)',
                    'No Registration (Open / Walk-in)',
                  ].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C32))),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _registrationType = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // TOTAL SEATS *
            Row(
              children: const [
                Text("TOTAL SEATS ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              ],
            ),
            CheckboxListTile(
              activeColor: const Color(0xFFF7931A),
              contentPadding: EdgeInsets.zero,
              title: const Text("Unlimited Seats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              value: _unlimitedSeats,
              onChanged: (val) => setState(() => _unlimitedSeats = val ?? false),
            ),
            if (!_unlimitedSeats) ...[
              const SizedBox(height: 6),
              TextField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: myInputDecor("Number of seats (e.g. 100)"),
              ),
            ],
            const Divider(color: Colors.white24, height: 24),

            // PAYMENT SETTINGS
            const Text("PAYMENT SETTINGS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const Text("Choose how users pay for event registration.", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 12),
            Column(
              children: [
                _paymentMethodTile("Free", "No entry fee required to join the event."),
                const SizedBox(height: 8),
                _paymentMethodTile("Manual Transaction", "Users scan your QR code/UPI ID and submit Transaction ID."),
                const SizedBox(height: 8),
                _paymentMethodTile("College Portal", "Direct users to official college payment portal URL."),
              ],
            ),

            // Screenshot 2 & 3 Payment Details
            if (_paymentMethod != 'Free') ...[
              const SizedBox(height: 14),
              Row(
                children: const [
                  Text("REGISTRATION FEE (₹) ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _entryFeeController,
                keyboardType: TextInputType.number,
                decoration: myInputDecor("0"),
              ),
              const SizedBox(height: 14),

              if (_paymentMethod == 'Manual Transaction') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text("UPI ID / PHONE NUMBER ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _upiIdController,
                            decoration: myInputDecor("e.g. name@upi or 9876543210"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ACCOUNT HOLDER NAME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _accountHolderNameController,
                            decoration: myInputDecor("e.g. Club Secretary or Club Account Name"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text("CUSTOM PAYMENT INSTRUCTIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _customPaymentInstructionsController,
                  maxLines: 3,
                  decoration: myInputDecor("Add custom instructions for the user (e.g. Please scan the QR code, pay via GPay/PhonePe/Paytm, and paste the 12-digit UTR/Transaction ID below.)"),
                ),
              ],

              if (_paymentMethod == 'College Portal') ...[
                Row(
                  children: const [
                    Text("COLLEGE PAYMENT PORTAL URL ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _collegePaymentUrlController,
                  decoration: myInputDecor("https://payments.college.ac.in/event-fee"),
                ),
                const SizedBox(height: 14),
                const Text("CUSTOM PAYMENT INSTRUCTIONS (OPTIONAL)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _customPaymentInstructionsController,
                  maxLines: 3,
                  decoration: myInputDecor("Add custom instructions for payment on the college portal."),
                ),
              ],
            ],

            const Divider(color: Colors.white24, height: 24),

            // POST-REGISTRATION MESSAGE (OPTIONAL)
            const Text("POST-REGISTRATION MESSAGE (OPTIONAL)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const Text("Show a WhatsApp group link, Discord invite, or instructions after successful registration.", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 6),
            TextField(
              controller: _postRegistrationMsgController,
              maxLines: 3,
              decoration: myInputDecor("e.g. Join our WhatsApp group: https://chat.whatsapp.com/... or Follow the next steps at..."),
            ),

            const Divider(color: Colors.white24, height: 24),

            // REQUIRED STUDENT INFORMATION
            const Text("REQUIRED STUDENT INFORMATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const Text("Select which profile fields students must complete before registering.", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                'GitHub Profile',
                'LinkedIn Profile',
                'X (Twitter) Profile',
                'Portfolio URL',
              ].map((field) {
                final checked = _requiredStudentInfo.contains(field);
                return CheckboxListTile(
                  dense: true,
                  activeColor: const Color(0xFFF7931A),
                  contentPadding: EdgeInsets.zero,
                  title: Text(field, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  value: checked,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _requiredStudentInfo.add(field);
                      } else {
                        _requiredStudentInfo.remove(field);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const Divider(color: Colors.white24, height: 24),

            // CUSTOM REGISTRATION FIELDS (Screenshot 5)
            const Text("CUSTOM REGISTRATION FIELDS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const Text("Add custom fields that students must fill during registration (like Google Forms)", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 12),

            ..._customFields.asMap().entries.map((entry) {
              final idx = entry.key;
              final cf = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text("Field Label ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: cf.labelController,
                                decoration: myInputDecor("e.g. Team Name, GitHub Repo..."),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Field Type", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: cf.type,
                                    isExpanded: true,
                                    items: ['Text', 'Number', 'Dropdown', 'File'].map((t) {
                                      return DropdownMenuItem<String>(
                                        value: t,
                                        child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => cf.type = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              _customFields.removeAt(idx);
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: const Color(0xFFF7931A),
                          value: cf.required,
                          onChanged: (val) => setState(() => cf.required = val ?? false),
                        ),
                        const Text("Required", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              );
            }),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _customFields.add(CustomFieldInput());
                });
              },
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF7931A), size: 18),
              label: const Text("Add Custom Field", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFF7931A), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("⇽ BACK", style: TextStyle(color: Color(0xFF191C32), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 4),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("NEXT STEP ➔", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentMethodTile(String method, String description) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFF7931A) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFFF7931A) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C32))),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: EXTRAS & PUBLISHING (Exact Cards as Screenshots 4 & 5)
  Widget _buildStep4ExtrasAndPublishing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STEP 4: EXTRAS & PUBLISHING", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C32))),
        const Text("Add certificates, results display options, custom sponsors, and media resources.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        _buildDarkSection(
          children: [
            // Screenshot 4 Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CheckboxListTile(
                      dense: true,
                      activeColor: const Color(0xFFF7931A),
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Display Results / Winners", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF191C32))),
                      subtitle: const Text("Show winners on the event card after completion.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      value: _displayResults,
                      onChanged: (val) => setState(() => _displayResults = val ?? false),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CheckboxListTile(
                      dense: true,
                      activeColor: const Color(0xFF5FC88F),
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Digital Certificates", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF191C32))),
                      subtitle: const Text("Enable downloadable certificates for participants.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      value: _digitalCertificates,
                      onChanged: (val) => setState(() => _digitalCertificates = val ?? false),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),

            // SPONSORS (Screenshot 4 & 5)
            const Text("SPONSORS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const Text("Add sponsors for this event (optional)", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 10),
            ..._sponsors.asMap().entries.map((entry) {
              final idx = entry.key;
              final sp = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text("Sponsor Name ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextField(controller: sp.nameController, decoration: myInputDecor("e.g. Acme Corp")),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text("Logo URL ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text("*", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextField(controller: sp.logoUrlController, decoration: myInputDecor("https://example.com/logo.png")),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => setState(() => _sponsors.removeAt(idx)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Website URL (optional)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        TextField(controller: sp.websiteUrlController, decoration: myInputDecor("https://sponsor-website.com")),
                      ],
                    ),
                  ],
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: () => setState(() => _sponsors.add(SponsorInput())),
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF7931A)),
              label: const Text("Add Sponsor", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                side: const BorderSide(color: Color(0xFFF7931A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const Divider(color: Colors.white24, height: 24),

            // MEDIA (Screenshot 4)
            const Text("MEDIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const Text("Add images, videos, or sponsor logos for this event (optional)", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 10),
            ..._mediaLinks.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: m.type,
                                isExpanded: true,
                                items: ['Video', 'Image', 'Sponsor Logo', 'Document / Link'].map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t,
                                    child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => m.type = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => setState(() => _mediaLinks.removeAt(idx)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(controller: m.titleController, decoration: myInputDecor("Title * (e.g. Teaser Video)")),
                    const SizedBox(height: 6),
                    TextField(controller: m.urlController, decoration: myInputDecor("URL * (https://...)")),
                  ],
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: () => setState(() => _mediaLinks.add(MediaInput())),
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF7931A)),
              label: const Text("Add Media", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                side: const BorderSide(color: Color(0xFFF7931A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _previewEvent,
          icon: const Icon(Icons.remove_red_eye, color: Color(0xFFF7931A)),
          label: const Text("PREVIEW EVENT 👁", style: TextStyle(color: Color(0xFFF7931A), fontWeight: FontWeight.bold, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(55),
            side: const BorderSide(color: Color(0xFFF7931A), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 3),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("⇽ BACK", style: TextStyle(color: Color(0xFF191C32), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("CREATE EVENT 🚀", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDarkSection({required List<Widget> children}) {
    return Material(
      color: const Color(0xFF191C32),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

InputDecoration myInputDecor(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9395A4), fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFF7931A), width: 1.5),
    ),
  );
}
