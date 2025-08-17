import 'package:flutter/material.dart';

class Adminscreen2 extends StatelessWidget {
  final Function(int) changeindex;
  const Adminscreen2({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: Color(0xFF191C32),
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
            color: Color(0xFF191C32),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    // Add padding to prevent it from touching the edge
                    padding: const EdgeInsets.only(top: 16, left: 24),
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
                            Text(
                              "EVENT INFO",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            mycontainer1(
                              context,
                              "Event Title",
                              "Event Description",
                              "Event Name",
                              "Event Details",
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "SCHEDULE SECTION",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            mycontainer2(
                              context,
                              "Start Date",
                              "Start Time",
                              "End Date",
                              "End Time",
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "LOCATION SECTION",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            mycontainer1(
                              context,
                              "PHYSICAL EVENT",
                              "VIRTUAL EVENT",
                              "Venue Name",
                              "Meeting Link",
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "MEDIA SECTION",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            mycontainer1(
                              context,
                              "Upload Event Poster",
                              "Upload Video (Optional)",
                              "Image File Upload",
                              "Video File Upload",
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "ADDTIONAL OPTIONS",
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            mycontainer1(
                              context,
                              "MAX PARTICIPANTS",
                              "CONTACT INFO",
                              "Max Number",
                              "Contact Number",
                            ),
                            SizedBox(
                              height: height * 0.05,
                            ),
                            mybutton("SAVE AS DRAFT"),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            mybutton("PUBLISH EVENT"),
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

ElevatedButton mybutton(String name) {
  return ElevatedButton(
    onPressed: () {},
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Color(0xFF191C32)),
      fixedSize: WidgetStatePropertyAll(Size.fromHeight(65),),
    ),
    child: Text(
      name,
      selectionColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );
}

InputDecoration myDecoration(String hintText) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.white), // <- when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.grey, width: 1), // <- when focused
    ),
  );
}

Container mycontainer1(BuildContext context, String title1, String title2,
    String hint1, String hint2) {
  final double height = MediaQuery.of(context).size.height;
  final double width = MediaQuery.of(context).size.width;
  return Container(
    padding: EdgeInsets.all(16),
    width: width,
    decoration: BoxDecoration(
        color: Color(0xFF191C32), borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title1,
          style: TextStyle(
              letterSpacing: -1,
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.white),
        ),
        SizedBox(
          height: height * 0.01,
        ),
        TextField(
          decoration: myDecoration(
            hint1,
          ),
        ),
        SizedBox(
          height: height * 0.02,
        ),
        Text(
          title2,
          style: TextStyle(
              letterSpacing: -1,
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.white),
        ),
        SizedBox(
          height: height * 0.01,
        ),
        TextField(
          decoration: myDecoration(
            hint2,
          ),
        )
      ],
    ),
  );
}

Container mycontainer2(BuildContext context, String title1, String title2,
    String title3, String title4) {
  final double height = MediaQuery.of(context).size.height;
  final double width = MediaQuery.of(context).size.width;
  return Container(
    padding: EdgeInsets.all(16),
    width: width,
    decoration: BoxDecoration(
        color: Color(0xFF191C32), borderRadius: BorderRadius.circular(20)),
    child: Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: TextStyle(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextField(
                    decoration: myDecoration(
                      title1,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text(
                    title2,
                    style: TextStyle(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  TextField(
                    decoration: myDecoration(
                      title2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: width * 0.05,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title3,
                    style: TextStyle(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextField(
                    decoration: myDecoration(
                      title3,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text(
                    title4,
                    style: TextStyle(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  TextField(
                    decoration: myDecoration(
                      title4,
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
