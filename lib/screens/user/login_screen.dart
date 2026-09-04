import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/components/app_primary_button.dart';
import 'package:xplore_app/components/app_text_field.dart';
import 'package:xplore_app/screens/admin/admin_login_screen.dart';
import 'package:xplore_app/screens/admin/admin_portal_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';
import 'package:xplore_app/screens/user/register_screen.dart';
import 'package:xplore_app/screens/head/head_portal_screen.dart';
import 'package:xplore_app/screens/unused/forgot_password_roll_screen.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter both email and password.");
      return;
    }
    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.role == 'admin' || state.role == 'paymentAdmin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminPortalScreen(adminRole: state.role),
                ),
              );
            } else if (state.role == 'club') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HeadPortalScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserPortalScreen()),
              );
            }
          } else if (state is Needs2FA) {
            _showSnackBar('OTP sent to ${state.email}');
          } else if (state is AuthError) {
            _showSnackBar(state.message);
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            body: Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 5),
                    Image.asset(
                      "assets/screen1.png",
                      height: 240,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "LOGIN",
                          selectionColor: AppColors.primary,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _emailController,
                            hintText: "college email id",
                            prefixIcon: FontAwesomeIcons.envelope,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            prefixIcon: FontAwesomeIcons.lock,
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordRollScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AppPrimaryButton(
                            onPressed: _handleStudentLogin,
                            label: "LOG IN",
                            height: 50,
                            radius: 40,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Admin Portal Navigation Button ────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminLoginScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppColors.primary,
                                  size: 20),
                              label: const Text(
                                "ADMIN PORTAL LOGIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                // Loading indicator overlay
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
