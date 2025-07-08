import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 247, 250, 1),
        body: ListView(
          children: [
            Image.asset(
              "assets/screen2.png",
              height: 330,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "LOGIN",
                  selectionColor: Color(0xFF1D1049),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Column(
                children: [
                  SizedBox(
                    height:60 ,
                    child: TextField(
                        cursorColor: Color(0xFF1D1049),
                        // style: TextStyle(color: Colors.white),
                        obscureText: false,
                        decoration: myDecoration(
                            "Official Email ID", FontAwesomeIcons.envelope)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      cursorColor: Color(0xFF1D1049),
                      // style: TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration:
                          myDecoration("Password", FontAwesomeIcons.lock)),
                ],
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF191C32)),
                    fixedSize: WidgetStatePropertyAll(Size.fromHeight(65))),
                child: Text(
                  "LOGIN",
                  selectionColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: (){},
                child: Text(
                  "FORGOT PASSWORD?",
                  style: TextStyle(
                      color: Color(0xFF000000), fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
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
          BoxDecoration(color: Color(0xFFDEF5E9), shape: BoxShape.circle),
      child: Icon(
        size: 20,
        youricon,
        color: Color(0xFF5FC88F),
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
