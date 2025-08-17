import 'package:flutter/material.dart';
import 'hscreen1.dart';

class HomeScreen2 extends StatelessWidget {
  final Function(int) changeindex;
  const HomeScreen2({super.key, required this.changeindex});

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
                      "Registered\nEvents",
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
                        height: height * 0.02,
                      ),
                      Container(
                        height: height * 0.7,
                        margin: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 5,
                          // padding: EdgeInsets.only(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < 4) {
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: EventTile(
                                  imagelocation: "assets/gdgc.png",
                                  title: "GDGC CLUB",
                                  subtitle: "Free Workshop",
                                  onTap: () {},
                                  type: TrailingType.typeRegistered,
                                ),
                              );
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "No More Events",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromRGBO(0, 0, 0, 0.65)),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Tap to Register ?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.65)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
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
