import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final String usermail = "vikrant@nitj.ac.in";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;
        final bool isPotrait = (MediaQuery.of(context).orientation == Orientation.portrait);
        return Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFFF3F5F6),
              Color(0xFFFFCA3A),
            ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                      left: width * 0.05,
                    )),
                    IconButton(
                      iconSize: 32,
                      onPressed: () {},
                      splashColor: Colors.grey.withAlpha(64),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.04,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: AutoSizeText(
                    "OTP Verification",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 42),
                    maxLines: 1,
                    minFontSize: 20,
                    maxFontSize: 42,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.05,
                      ),
                    ),
                    Text(
                      "Enter the OTP sent to ",
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      usermail,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.05,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    otpholder(),
                    otpholder(),
                    otpholder(),
                    otpholder(),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn’t you receive the OTP? ",
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "RESEND OTP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                Spacer(),
                Visibility(
                  visible: isPotrait,
                  child: SizedBox(
                    height: height*0.45, // Responsive keypad height
                    child: keypad(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

Container otpholder() {
  return Container(
    height: 68,
    width: 54,
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
  );
}

Container keypad() {
  return Container(
    padding: EdgeInsets.all(20),
    height: 400,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [digit('1'), digit('2'), digit('3')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [digit('4'), digit('5'), digit('6')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [digit('7'), digit('8'), digit('9')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [digit('*'), digit('0'), digit('x')],
        )
      ],
    ),
  );
}

TextButton digit(String digit) {
  return TextButton(
    onPressed: () {},
    child: Text(
      digit,
      style: TextStyle(fontSize: 40, color: Colors.black),
    ),
  );
}
