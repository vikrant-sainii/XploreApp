import 'package:flutter/material.dart';

class EventManagement extends StatelessWidget {
  final Function(int) changeindex;
  const EventManagement({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: Color(0xFFF7F7FA),
        leading: Row(
          children: [
            const SizedBox(width: 8), // This adds your space on the left
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              // This is the correct way to style an IconButton
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(), // Makes the background a circle
              ),
              onPressed: () {
                changeindex(0);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 30,
            icon: Icon(Icons.more_vert),
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            color: Colors.black,
          ),
          Padding(padding: EdgeInsets.all(8))
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Container(
            color: Color(0xFFF7F7FA),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    // Add padding to prevent it from touching the edge
                    padding: const EdgeInsets.only(top: 16, left: 24),
                    child: Text(
                      "Event\nManagement",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        letterSpacing: -1,
                        fontWeight: FontWeight.w600,
                        fontSize: 37,
                      ),
                    ),
                  ),
                ),
                // 2. Align the Image to the top-right
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
                    borderRadius: BorderRadius.circular(40),
                    color: Color(0xFF191C32),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Container(
                        color: Color(0xFF191C32),
                        height: height * 0.7,
                        margin: EdgeInsets.symmetric(
                          horizontal: width * 0.06,
                        ),
                        child: ListView(
                          children: [
                            // ADD EVENT Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "ADD EVENT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.black),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            // Stats Grid Enclosed in Purple
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.3,
                                children: [
                                  _statCard("20", "TOTAL\nEVENTS"),
                                  _statCard("18", "COMPLETED\nEVENTS"),
                                  _statCard("2", "UPCOMING\nEVENTS"),
                                  _statCard("200", "PARTICIPANTS\nJOINED"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),
                            // EVENTS LIST Section
                            const Text(
                              "EVENTS LIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Event List Item
                            _eventListItem("WINTERFEST",
                                "25-26 FEB , 6:00PM\nVENUE-WE2", "COMPLETED"),
                            const SizedBox(
                                height: 100), // Bottom spacing for nav bar
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _statCard(String value, String label) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C32),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

Widget _eventListItem(String title, String details, String status) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha(50),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF191C32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const Text(
              "STATUS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            Text(
              status,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C32),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
