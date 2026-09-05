import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/models/event_model.dart';

class HeadEventPreviewScreen extends StatefulWidget {
  final Function(int) changeindex;
  final EventModel? event;

  const HeadEventPreviewScreen({
    super.key,
    required this.changeindex,
    this.event,
  });

  @override
  State<HeadEventPreviewScreen> createState() => _HeadEventPreviewScreenState();
}

class _HeadEventPreviewScreenState extends State<HeadEventPreviewScreen> {
  bool _isEditing = false;

  late TextEditingController _titleController;
  late TextEditingController _venueController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleController = TextEditingController(text: e?.title ?? "GDGC Workshop");
    _venueController = TextEditingController(text: e?.venue != null ? "Venue : ${e!.venue}" : "Venue : WE1");
    _timeController = TextEditingController(text: e?.formattedTime ?? "6.00 pm");
    _descriptionController = TextEditingController(
      text: e?.description ??
          "Join us for an interactive session covering cutting edge tech, software development workflows, and hands-on coding demos.",
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSaveEvent() {
    if (widget.event != null) {
      final updatedData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'venue': _venueController.text.replaceAll("Venue :", "").trim(),
      };
      context.read<HeadBloc>().add(UpdateClubEvent(widget.event!.id, updatedData));
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HeadBloc, HeadState>(
      listener: (context, state) {
        if (state is HeadActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
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
                onPressed: () => widget.changeindex(0),
              ),
            ],
          ),
          title: const Text(
            "EVENT PREVIEW",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        body: LayoutBuilder(
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
                      padding: const EdgeInsets.only(top: 16, left: 24),
                      child: _isEditing
                          ? SizedBox(
                              width: width * 0.5,
                              child: TextField(
                                controller: _titleController,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Title",
                                  hintStyle: TextStyle(color: Colors.white54),
                                ),
                              ),
                            )
                          : Text(
                              _titleController.text,
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/pillar.png",
                          height: height * 0.25,
                          width: width * 0.5,
                        ),
                        Positioned(
                          top: 10,
                          right: 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                _isEditing ? Icons.check : Icons.edit,
                                color: const Color(0xFFFF9AB2),
                              ),
                              onPressed: () {
                                if (_isEditing) {
                                  _handleSaveEvent();
                                } else {
                                  setState(() => _isEditing = true);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _isEditing
                                    ? TextField(
                                        controller: _titleController,
                                        style: const TextStyle(
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: UnderlineInputBorder(),
                                        ),
                                      )
                                    : Text(
                                        _titleController.text,
                                        style: const TextStyle(
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                              ),
                              _isEditing
                                  ? SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: _timeController,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          hintText: "Time",
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _timeController.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF7931A),
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _isEditing
                              ? TextField(
                                  controller: _venueController,
                                  style: const TextStyle(
                                    color: Color(0xFF9395A4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: "Enter Venue",
                                  ),
                                )
                              : Text(
                                  _venueController.text,
                                  style: const TextStyle(
                                    color: Color(0xFF9395A4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          const SizedBox(height: 20),
                          const Text(
                            "Description",
                            style: TextStyle(
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF191C32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isEditing
                              ? TextField(
                                  controller: _descriptionController,
                                  maxLines: null,
                                  style: const TextStyle(
                                    color: Color(0xFF9395A4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter Description",
                                  ),
                                )
                              : Text(
                                  _descriptionController.text,
                                  style: const TextStyle(
                                    color: Color(0xFF9395A4),
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                          const SizedBox(height: 24),
                          const Text(
                            "Previous Event Highlight",
                            style: TextStyle(
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF191C32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildHighlightCircle("assets/dogworkshop.png"),
                              const SizedBox(width: 12),
                              _buildHighlightCircle("assets/gdgc.png"),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "OUR EVENT",
                            style: TextStyle(
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF191C32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              "assets/workshopevent.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 100),
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

  Widget _buildHighlightCircle(String asset) {
    return CircleAvatar(
      radius: 36,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipOval(
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
