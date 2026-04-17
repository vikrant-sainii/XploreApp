import 'package:flutter/material.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final Function(int) changeindex;
  const UserProfileScreen({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: Color(0xFFF3E7EF),
        leading: Row(
          children: [
            const SizedBox(width: 8), // This adds your space on the left
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                changeindex(0);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: IconButton.styleFrom(backgroundColor: Colors.white),
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
            color: Color(0xFFF3E7EF),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: height * 0.1,
                      left: width * 0.02,
                      right: width * 0.02),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Container(
                        height: height * 0.8,
                        margin: EdgeInsets.symmetric(
                          horizontal: width * 0.06,
                        ),
                        child: ListView(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(onPressed: (){}, icon: Icon(Icons.edit,size: width*0.1,)),
                              ],
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            Text(
                              "XYZ ABC",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              decoration: myDecoration("Roll No", Icons.person,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              decoration: myDecoration("Official Email Id", Icons.mail,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              decoration: myDecoration("Branch", Icons.category,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              decoration: myDecoration("Hostel Name", Icons.house_outlined,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              decoration: myDecoration("Room No", Icons.room,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              decoration: myDecoration("Skills", Icons.language,)
                            ),



                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    "assets/homescreen4.png",
                    width: width*0.4,
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

InputDecoration myDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    labelText: hintText,
    contentPadding: EdgeInsets.symmetric(vertical: 20),
    prefixIcon: Container(
      margin: EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: Color(0xFFFFEBE4), shape: BoxShape.circle),
      child: Icon(
        size: 20,
        youricon,
        color: Color(0xFFF7931A),
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.black), // <- when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.black, width: 1), // <- when focused
    ),
  );
}
