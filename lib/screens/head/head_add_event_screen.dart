import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class HeadAddEventScreen extends StatefulWidget {
  final Function(int) changeindex;
  const HeadAddEventScreen({super.key, required this.changeindex});

  @override
  State<HeadAddEventScreen> createState() => _HeadAddEventScreenState();
}

class _HeadAddEventScreenState extends State<HeadAddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _venueController = TextEditingController();
  final _linkController = TextEditingController();
  final _posterController = TextEditingController();
  final _videoController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _contactController = TextEditingController();


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _venueController.dispose();
    _linkController.dispose();
    _posterController.dispose();
    _videoController.dispose();
    _maxParticipantsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formattedMonth = picked.month.toString().padLeft(2, '0');
      final formattedDay = picked.day.toString().padLeft(2, '0');
      controller.text = "${picked.year}-$formattedMonth-$formattedDay";
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      controller.text = "$hourStr:$minuteStr";
    }
  }

  void _submitEvent(bool isDraft) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Title cannot be empty")),
      );
      return;
    }

    try {
      final authState = context.read<AuthBloc>().state;
      String? myClubId;
      if (authState is Authenticated) {
        myClubId = authState.user.clubId;
        if (myClubId == null && authState.user.memberships.isNotEmpty) {
          try {
            myClubId = authState.user.memberships.firstWhere(
              (m) => m.role.toUpperCase() == "HEAD",
              orElse: () => authState.user.memberships.first,
            ).clubId;
          } catch (_) {}
        }
      }

      final now = DateTime.now();
      DateTime startDateTime = now.add(const Duration(days: 2));
      DateTime endDateTime = now.add(const Duration(days: 2, hours: 2));

      try {
        if (_startDateController.text.isNotEmpty) {
          final dateParts = _startDateController.text.split('-');
          final timeParts = _startTimeController.text.isNotEmpty 
              ? _startTimeController.text.split(':') 
              : ['18', '00'];
          if (dateParts.length == 3) {
            startDateTime = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              timeParts.isNotEmpty ? int.parse(timeParts[0]) : 18,
              timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
            );
          }
        }
      } catch (_) {}

      try {
        if (_endDateController.text.isNotEmpty) {
          final dateParts = _endDateController.text.split('-');
          final timeParts = _endTimeController.text.isNotEmpty 
              ? _endTimeController.text.split(':') 
              : ['20', '00'];
          if (dateParts.length == 3) {
            endDateTime = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              timeParts.isNotEmpty ? int.parse(timeParts[0]) : 20,
              timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
            );
          }
        }
      } catch (_) {}

      final maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 100;

      final payload = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "venue": _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : "WE2",
        "startTime": startDateTime.toIso8601String(),
        "endTime": endDateTime.toIso8601String(),
        "totalSeats": maxParticipants,
        "entryFee": 0.0,
        "registrationFee": 0.0,
        "paymentMethod": "FREE",
        "registrationType": "individual",
        "minTeamSize": 1,
        "maxTeamSize": 1,
        "imageUrl": _posterController.text.trim().isNotEmpty 
            ? _posterController.text.trim() 
            : "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
        "imageLocation": _posterController.text.trim().isNotEmpty 
            ? _posterController.text.trim() 
            : "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
        if (myClubId != null) "clubId": myClubId,
        "allowedPrograms": ["BTECH", "MTECH", "OTHER"],
        "allowedYears": [],
        "allowedBranches": [],
        "reviewStatus": isDraft ? "draft" : "approved",
      };

      context.read<HeadBloc>().add(CreateEventRequested(payload));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit event: $e")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HeadBloc, HeadState>(
      listener: (context, state) {
        if (state is HeadEventOperationSuccess && state.actionType == 'create') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<EventBloc>().add(FetchAllEvents());
          context.read<HeadBloc>().add(FetchDashboardStats());
          widget.changeindex(3);
        } else if (state is HeadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(

      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            iconSize: 24,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardColor,
              shape: const CircleBorder(),
            ),
            onPressed: () {
              widget.changeindex(0);
            },
          ),
        ),
        actions: [
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardColor,
              shape: const CircleBorder(),
            ),
            color: Colors.white,
          ),
          const SizedBox(width: 12)
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Stack(
            children: [
              Container(
                color: AppColors.scaffoldBackground,
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 16, left: 24),
                        child: Text(
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
                          right: width * 0.02),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        color: AppColors.cardColor,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: ListView(
                          children: [
                            const Text(
                              "EVENT INFO",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContainer1(
                              "Event Title",
                              "Event Description",
                              "Event Name",
                              "Event Details",
                              _titleController,
                              _descriptionController,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "SCHEDULE SECTION",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContainer2(
                              "Start Date (YYYY-MM-DD)",
                              "Start Time (HH:MM)",
                              "End Date (YYYY-MM-DD)",
                              "End Time (HH:MM)",
                              _startDateController,
                              _startTimeController,
                              _endDateController,
                              _endTimeController,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "LOCATION SECTION",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContainer1(
                              "PHYSICAL EVENT",
                              "VIRTUAL EVENT",
                              "Venue Name",
                              "Meeting Link",
                              _venueController,
                              _linkController,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "MEDIA SECTION",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContainer1(
                              "Upload Event Poster URL",
                              "Upload Video URL (Optional)",
                              "Image URL",
                              "Video URL",
                              _posterController,
                              _videoController,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "ADDITIONAL OPTIONS",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContainer1(
                              "MAX PARTICIPANTS",
                              "CONTACT INFO",
                              "Max Number",
                              "Contact Number",
                              _maxParticipantsController,
                              _contactController,
                            ),
                            const SizedBox(height: 32),
                            _buildSubmitButton("SAVE AS DRAFT", () => _submitEvent(true)),
                            const SizedBox(height: 16),
                            _buildSubmitButton("PUBLISH EVENT", () => _submitEvent(false)),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<HeadBloc, HeadState>(
                builder: (context, state) {
                  if (state is HeadLoading) {
                    return Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    ),
  );
}



  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  InputDecoration _myDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.scaffoldBackground,
      hintText: hintText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildContainer1(String title1, String title2, String hint1, String hint2,
      TextEditingController controller1, TextEditingController controller2) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title1,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller1,
            style: const TextStyle(color: Colors.white),
            decoration: _myDecoration(hint1),
          ),
          const SizedBox(height: 16),
          Text(
            title2,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller2,
            style: const TextStyle(color: Colors.white),
            decoration: _myDecoration(hint2),
          )
        ],
      ),
    );
  }

  Widget _buildContainer2(
      String title1,
      String title2,
      String title3,
      String title4,
      TextEditingController controller1,
      TextEditingController controller2,
      TextEditingController controller3,
      TextEditingController controller4) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller1,
                      readOnly: true,
                      onTap: () => _selectDate(controller1),
                      style: const TextStyle(color: Colors.white),
                      decoration: _myDecoration(
                        "Select Date",
                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller2,
                      readOnly: true,
                      onTap: () => _selectTime(controller2),
                      style: const TextStyle(color: Colors.white),
                      decoration: _myDecoration(
                        "Select Time",
                        suffixIcon: const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title3,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller3,
                      readOnly: true,
                      onTap: () => _selectDate(controller3),
                      style: const TextStyle(color: Colors.white),
                      decoration: _myDecoration(
                        "Select Date",
                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title4,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller4,
                      readOnly: true,
                      onTap: () => _selectTime(controller4),
                      style: const TextStyle(color: Colors.white),
                      decoration: _myDecoration(
                        "Select Time",
                        suffixIcon: const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
