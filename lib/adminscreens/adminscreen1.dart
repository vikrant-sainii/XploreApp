import 'package:flutter/material.dart';
import '../Homepage/hscreen1.dart';

class Adminscreen1 extends StatelessWidget {
  final Function(int) changeindex;
  const Adminscreen1({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(MediaQuery.of(context).size.width),
        backgroundColor: Color(0xFFF7F7FA),
        body: LayoutBuilder(builder: (context, constraints) {
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
                      "assets/Promohead.png",
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
                        "Member Details",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.05,
              ),
              //general container(is used in screen 2 and screen 3)
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
                          "DASHBOARD",
                          style: TextStyle(
                              letterSpacing: -1,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        ),
                        SizedBox(
                          width: width * 0.05,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: (){},
                        child: Image.asset("assets/event.png"),
                      ),
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
                            onTap: () {
                              changeindex(1);
                            },
                            type: TrailingType.typeUpcoming,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }
      ),
    );
  }
} //general container(is used in screen 2 and screen 3)

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
            Image.asset(
              "assets/gdgc.png",
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
