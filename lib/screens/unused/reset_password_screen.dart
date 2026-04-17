import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(builder: (context, constraints) {
        double height = constraints.maxHeight;
        final bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFFE3C9), Color(0xFFD299B8)],
              ),
            ),
            child: ListView(
              children: [
                Image.asset(
                  "assets/newpass.png",
                  height: isPortrait ? height * 0.35 : height * 0.6,
                  // width: 0.8*width,
                ),
                SizedBox(
                  height: height*0.08,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextField(
                        decoration: myDecoration("New Password", Icons.lock),
                      ),
                      SizedBox(
                        height: 0.01*height,
                      ),
                      TextField(
                        decoration: myDecoration("Confirm Password", Icons.lock),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height*0.08,
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to login
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color(0xFF191C32)),
                        fixedSize: WidgetStatePropertyAll(Size.fromHeight(65))),
                    child: Text(
                      "CONFIRM",
                      selectionColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
}

InputDecoration myDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 20),
    prefixIcon: Container(
      margin: EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: Color(0xFFEBECFF), shape: BoxShape.circle),
      child: Icon(
        size: 20,
        youricon,
        color: Color(0xFF9F9DF3),
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.white), // <- when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.grey, width: 1), // <- when focused
    ),
  );
}

