import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/unused/reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, this.email = "student@nitj.ac.in"});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _enteredOtp = "";

  void _onDigitPressed(String digit) {
    if (_enteredOtp.length < 6) {
      setState(() {
        _enteredOtp += digit;
      });
    }
  }

  void _onBackspacePressed() {
    if (_enteredOtp.isNotEmpty) {
      setState(() {
        _enteredOtp = _enteredOtp.substring(0, _enteredOtp.length - 1);
      });
    }
  }

  void _handleVerify() {
    if (_enteredOtp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP"), backgroundColor: Colors.red),
      );
      return;
    }
    // Navigate to Reset Password Screen with the entered token / OTP
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(token: _enteredOtp, email: widget.email),
      ),
    );
  }

  void _handleResend() {
    context.read<AuthBloc>().add(ForgotPasswordRequested(widget.email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Resending OTP to ${widget.email}..."), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;
          double width = constraints.maxWidth;
          final bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);
          return Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF3F5F6),
                  Color(0xFFFFCA3A),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: width * 0.05)),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: const AutoSizeText(
                    "OTP Verification",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Text(
                    "Enter code sent to ${widget.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
                SizedBox(height: height * 0.03),

                // OTP Display Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final digit = index < _enteredOtp.length ? _enteredOtp[index] : "";
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 55,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: index == _enteredOtp.length ? const Color(0xFF191C32) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        digit,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),

                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the OTP? "),
                    GestureDetector(
                      onTap: _handleResend,
                      child: const Text(
                        "RESEND OTP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton(
                    onPressed: _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191C32),
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "VERIFY & CONTINUE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: isPortrait,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('1'),
                            _buildKeypadButton('2'),
                            _buildKeypadButton('3'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('4'),
                            _buildKeypadButton('5'),
                            _buildKeypadButton('6'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('7'),
                            _buildKeypadButton('8'),
                            _buildKeypadButton('9'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _enteredOtp = ""),
                              child: const Text("Clear", style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ),
                            _buildKeypadButton('0'),
                            IconButton(
                              icon: const Icon(Icons.backspace_outlined, size: 28, color: Colors.black),
                              onPressed: _onBackspacePressed,
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildKeypadButton(String digit) {
    return TextButton(
      onPressed: () => _onDigitPressed(digit),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }
}
