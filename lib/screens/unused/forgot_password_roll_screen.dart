import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/unused/reset_password_screen.dart';

/// Forgot-password entry screen.
/// The user enters their registered email address; the backend sends a reset
/// link. On success we show the ResetPasswordScreen (which requires the raw
/// token from the email link).
class ForgotPasswordRollScreen extends StatefulWidget {
  const ForgotPasswordRollScreen({super.key});

  @override
  State<ForgotPasswordRollScreen> createState() =>
      _ForgotPasswordRollScreenState();
}

class _ForgotPasswordRollScreenState extends State<ForgotPasswordRollScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    context.read<AuthBloc>().add(ForgotPasswordRequested(email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordLinkSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Reset link sent! Check your email and paste the token below.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(builder: (context, constraints) {
          final double height = constraints.maxHeight;
          final bool isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          return Container(
            decoration: const BoxDecoration(
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
                    const Padding(padding: EdgeInsets.only(left: 25)),
                    IconButton(
                      iconSize: 32,
                      onPressed: () => Navigator.pop(context),
                      splashColor: Colors.grey.withAlpha(64),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
                Image.asset(
                  "assets/roll_pass.png",
                  height: isPortrait ? height * 0.34 : height * 0.6,
                ),
                SizedBox(height: height * 0.04),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Enter your registered email address and we\'ll send you a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: _buildEmailField(),
                ),
                SizedBox(height: height * 0.07),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : _handleForgotPassword,
                        style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xFF191C32)),
                          fixedSize: WidgetStatePropertyAll(
                              Size.fromHeight(65)),
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'SEND RESET LINK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Color(0xFFFFEBE4), shape: BoxShape.circle),
          child: const Icon(Icons.email, size: 20, color: Color(0xFFF7931A)),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: 'Registered Email Address',
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}
