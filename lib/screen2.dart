import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xplore_app/homepage.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStudentLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(246, 247, 250, 1),
        body: ListView(
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  "assets/screen2.png",
                  height: 330,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "LOGIN",
                      selectionColor: Color(0xFF1D1049),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),



                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60,
                        child: TextField(
                          controller: _emailController,
                          cursorColor: const Color(0xFF1D1049),
                          obscureText: false,
                          enabled: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: myDecoration(
                              "Official Email ID", FontAwesomeIcons.envelope),
                          onSubmitted: (_) => _handleStudentLogin(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFF1D1049),
                        obscureText: true,
                        enabled: true,
                        decoration:
                            myDecoration("Password", FontAwesomeIcons.lock),
                        onSubmitted: (_) => _handleStudentLogin(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: ElevatedButton(
                    onPressed: _handleStudentLogin,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF191C32)),
                      fixedSize: const WidgetStatePropertyAll(Size.fromHeight(65)),
                    ),
                    child: const Text(
                      "LOGIN",
                      selectionColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showForgotPasswordDialog();
                    },
                    child: const Text(
                      "FORGOT PASSWORD?",
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to reset your password:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here you can implement forgot password functionality
                // For now, just show a message
                Navigator.of(context).pop();
                _showSnackBar(
                    'Password reset functionality not implemented yet');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF191C32),
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

InputDecoration myDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 20),
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration:
          const BoxDecoration(color: Color(0xFFDEF5E9), shape: BoxShape.circle),
      child: Icon(
        size: 20,
        youricon,
        color: const Color(0xFF5FC88F),
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.white),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: Colors.grey),
    ),
  );
}
