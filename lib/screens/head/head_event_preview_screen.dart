import 'package:flutter/material.dart';

class HeadEventPreviewScreen extends StatefulWidget {
  final Function(int) changeindex;
  const HeadEventPreviewScreen({super.key, required this.changeindex});

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
    _titleController = TextEditingController(text: "GDGC Workshop");
    _venueController = TextEditingController(text: "Venue : WE1");
    _timeController = TextEditingController(text: "6.00 pm");
    _descriptionController = TextEditingController(
      text: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Consequatur optio earum quae consectetur, iure possimus aliquid esse dicta totam perferendis molestiae pariatur est cum inventore voluptatibus numquam iusto quidem. Maxime",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: const Color(0xFFFF9AB2),
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              onPressed: () {
                widget.changeindex(0);
              },
            ),
          ],
        ),
        title: const Text(
          "EVENT PREVIEW",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            color: Colors.black,
          ),
          const Padding(padding: EdgeInsets.all(8))
        ],
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
                              fontSize: 32,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Title",
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        )
                      : Text(
                          _titleController.text.replaceAll(" ", "\n"),
                          style: const TextStyle(
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
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: height * 0.22,
                    left: width * 0.02,
                    right: width * 0.02,
                  ),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color(0xFFF7F7FA),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 23,
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 23,
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
                                      fontSize: 17,
                                      letterSpacing: -1,
                                      fontWeight: FontWeight.w500
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
                                    fontSize: 17,
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w500
                                  ),
                                )
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                          ? TextField(
                              controller: _venueController,
                              style: const TextStyle(
                                color: Color(0xFF9395A4),
                                fontWeight: FontWeight.w500
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
                                fontWeight: FontWeight.w500
                              ),
                            ),
                        const SizedBox(height: 24),
                        const Text(
                          "Description",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                          ? TextField(
                              controller: _descriptionController,
                              maxLines: null,
                              style: const TextStyle(
                                color: Color(0xFF9395A4),
                                fontWeight: FontWeight.w500
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
                                fontWeight: FontWeight.w500
                              ),
                            ),
                        const SizedBox(height: 32),
                        const Text(
                          "Previous Event Highlight",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildHighlightCircle("assets/dogworkshop.png"),
                            const SizedBox(width: 12),
                            _buildHighlightCircle("assets/dogworkshop.png"),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "OUR EVENT",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(height: 16),
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
    );
  }

  Widget _buildHighlightCircle(String asset) {
    return CircleAvatar(
      radius: 45,
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
