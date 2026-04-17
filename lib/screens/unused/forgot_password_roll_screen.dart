import 'package:flutter/material.dart';
import 'package:xplore_app/screens/unused/otp_verification_screen.dart';

class ForgotPasswordRollScreen extends StatelessWidget {
  const ForgotPasswordRollScreen({super.key});

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
                colors: [Color(0xFFFFE3C9), Color.fromARGB(255, 134, 125, 183)],
              ),
            ),
            child: ListView(
              children: [
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 25)),
                    IconButton(
                      iconSize: 32,
                      onPressed: () => Navigator.pop(context),
                      splashColor: Colors.grey.withAlpha(64),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height*0.04,
                ),
                Image.asset(
                  "assets/roll_pass.png",
                  height: isPortrait ? height * 0.34 : height * 0.6,
                ),
                SizedBox(
                  height: height*0.06,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextField(
                        decoration: myDecoration("Roll No", Icons.person),
                        obscureText: false,
                      ),
                      SizedBox(
                        height: 0.01*height,
                      ),
                      TextField(
                        decoration: myDecoration("Enter Password", Icons.lock),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height*0.07,
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OtpVerificationScreen()),
                      );
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
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.white), // <- when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.grey, width: 1), // <- when focused
    ),
  );
}
