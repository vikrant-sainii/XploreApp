import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen1 extends StatelessWidget {
  const HomeScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(MediaQuery.of(context).size.width),
      backgroundColor: Color(0xFFF7F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return ListView(
            children: [
              SizedBox(
                height: height * 0.05,
              ),
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Image.asset(
                      "assets/welcframe.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.015,
                    left: width * 0.1,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        "Tap to Xplore",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Color(0xFFF7F7FA)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.05,
                        ),
                        Text(
                          "Registered Events",
                          style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Container(
                      height: height * 0.17,
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 4,
                        padding: EdgeInsets.only(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return EventTile(
                            imagelocation: "assets/gdgc.png",
                            title: "GDGC CLUB",
                            subtitle: "Free Workshop",
                            onTap: () {},
                            type: TrailingType.typeRegistered,
                          );
                        },
                      ),
                    ),
                    XploreTile(
                      onTap: () {},
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.05,
                        ),
                        Text(
                          "Upcoming Events",
                          style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Container(
                      height: height * 0.17,
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 4,
                        padding: EdgeInsets.only(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return EventTile(
                            imagelocation: "assets/octave.png",
                            title: "Octave",
                            subtitle: "Venue : A3,Civil Building",
                            onTap: () {},
                            type: TrailingType.typeUpcoming,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//functions for optimisation

enum TrailingType { typeUpcoming, typeRegistered }

Widget buildTrailing(TrailingType type, VoidCallback? onTap) {
  switch (type) {
    case (TrailingType.typeUpcoming):
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("5:30 PM", style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.angleUp, size: 14, color: Colors.orange),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "See More Info",
                  style: TextStyle(letterSpacing: -1, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      );
    case (TrailingType.typeRegistered):
      return IconButton(
        onPressed: onTap,
        icon: Icon(FontAwesomeIcons.angleDown),
        color: Color(0xFFF7931A),
      );
  }
}

//Event Tile-registerd/upcoming
class EventTile extends StatelessWidget {
  final String imagelocation, title, subtitle;
  final VoidCallback? onTap;
  final TrailingType type;

  const EventTile({
    super.key,
    required this.imagelocation,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height;
    final maxWidth = MediaQuery.sizeOf(context).width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      width: 0.9 * maxWidth,
      height: 0.08 * maxHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        leading: Image.asset(
          imagelocation,
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Color(0xFF9395A4)),
        ),
        trailing: buildTrailing(type, onTap)
      ),
    );
  }
}

//Upcoming Events Tile
class XploreTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;

  const XploreTile({
    super.key,
    this.onTap,
    this.title = "Xplore More",
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      height: height * 0.04,
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          SizedBox(width: width * 0.1),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 0.05),
            child: IconButton(
              onPressed: onTap,
              icon: Icon(FontAwesomeIcons.angleDown),
              color: Color(0xFFF7931A),
            ),
          ),
        ],
      ),
    );
  }
}

//app bar
PreferredSizeWidget customAppBar(double width) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(40), // app bar height
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 32,
              color: Colors.black,
            ),
            SizedBox(width: width * 0.04),
            const Text(
              "Welcome Home",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
