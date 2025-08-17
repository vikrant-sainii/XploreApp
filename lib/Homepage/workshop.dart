import 'package:flutter/material.dart';

enum EventDraft{yes,no} //function optimisation

class Workshop extends StatelessWidget {
  final Function(int) changeindex;
  final EventDraft preview ;
  const Workshop({super.key, required this.changeindex,required this.preview});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: Color(0xFFFF9AB2),
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
        title: preview==EventDraft.yes? Text(
          "EVENT PREVIEW",
          style: TextStyle(
            color: Colors.white,
            // letterSpacing: -1,
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ):null,
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
            color: Color(0xFFFF9AB2),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    // Add padding to prevent it from touching the edge
                    padding: const EdgeInsets.only(top: 16, left: 24),
                    child: Text(
                      "Bhangra\nWorkshop",
                      style: TextStyle(
                        color: Colors.white,
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
                    color: Color(0xFFF7F7FA),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Container(
                        height: height * 0.7,
                        margin: EdgeInsets.symmetric(
                          horizontal: width * 0.06,
                        ),
                        child: ListView(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Bhangra Workshop",
                                  style: TextStyle(
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 23,
                                  ),
                                ),
                                Text(
                                  "5.30 pm",
                                  style: TextStyle(
                                      fontSize: 17,
                                      letterSpacing: -1,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            Text(
                              'Venue : A3,Civil Building',
                              style: TextStyle(
                                  color: Color(0xFF9395A4),
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "Description",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w500,
                                fontSize: 23,
                              ),
                            ),
                            Text(
                              'Lorem ipsum dolor sit amet consectetur adipisicing elit. Consequatur optio earum quae consectetur, iure possimus aliquid esse dicta totam perferendis molestiae pariatur est cum inventore voluptatibus numquam iusto quidem. Maxime',
                              style: TextStyle(
                                  color: Color(0xFF9395A4),
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "Previous Event Highlight",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w500,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  child: Image.asset("assets/dogworkshop.png"),
                                ),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                                CircleAvatar(
                                  radius: 50,
                                  child: Image.asset("assets/dogworkshop.png"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "OUR EVENT",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w500,
                                fontSize: 23,
                              ),
                            ),
                            Image.asset(
                                "assets/workshopevent.png",
                                fit: BoxFit.cover,
                            ),
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

