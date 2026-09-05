import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/screens/admin/admin_dashboard_screen.dart';
import 'package:xplore_app/screens/head/head_portal_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';
import 'package:xplore_app/screens/user/register_screen.dart';
import 'package:xplore_app/screens/unused/forgot_password_roll_screen.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/services/api_config.dart';

enum LoginMode { student, admin, external }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _twoFactorOtpController = TextEditingController();

  LoginMode _selectedMode = LoginMode.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _twoFactorOtpController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Please enter your email");
      return;
    }

    if (_selectedMode == LoginMode.student) {
      final password = _passwordController.text;
      if (password.isEmpty) {
        _showSnackBar("Please enter your password");
        return;
      }
      context.read<AuthBloc>().add(LoginRequested(email, password, isAdmin: false));
    } else if (_selectedMode == LoginMode.admin) {
      final password = _passwordController.text;
      if (password.isEmpty) {
        _showSnackBar("Please enter your admin password");
        return;
      }
      context.read<AuthBloc>().add(LoginRequested(email, password, isAdmin: true));
    } else if (_selectedMode == LoginMode.external) {
      final otp = _otpController.text.trim();
      if (otp.isEmpty) {
        _showSnackBar("Please enter the 6-digit access code");
        return;
      }
      context.read<AuthBloc>().add(ExternalLoginRequested(email, otp));
    }
  }

  void _show2FADialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Two-Factor Authentication", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter the 2FA OTP code sent to $email:", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _twoFactorOtpController,
              keyboardType: TextInputType.number,
              decoration: myDecoration("2FA OTP Code", Icons.security),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = _twoFactorOtpController.text.trim();
              if (otp.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(Verify2FARequested(email, otp));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF191C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Verify", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Preload clubs & events for the authenticated user
          context.read<ClubBloc>().add(FetchUserClubs(user: state.user));
          context.read<EventBloc>().add(FetchAllEvents(userId: state.user.id));
          final roleUpper = state.user.role.toUpperCase();
          final userTypeLower = (state.user.userType ?? '').toLowerCase();

          if (state.user.isAdmin ||
              roleUpper == 'ADMIN' ||
              roleUpper == 'PLATFORMADMIN' ||
              roleUpper == 'FACULTYCOORDINATOR' ||
              roleUpper == 'FACULTY_COORDINATOR' ||
              roleUpper == 'FACULTY' ||
              roleUpper == 'LOSTFOUNDADMIN' ||
              roleUpper == 'PAYMENTADMIN' ||
              userTypeLower == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else if (state.user.isClubAccount ||
                     roleUpper == 'CLUB_ACCOUNT' ||
                     userTypeLower == 'club_account') {
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
        } else if (state is AuthNeeds2FA) {
          _show2FADialog(state.email);
        } else if (state is AuthError) {
          _showSnackBar(state.message);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(246, 247, 250, 1),
          body: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    "assets/screen2.png",
                    height: 220,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color(0xFF1D1049),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Color(0xFFF7931A), size: 22),
                        tooltip: "Server Settings",
                        onPressed: () => ApiConfig.showServerConfigDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mode Selector Tabs (Student / Admin / External)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildModeTab("Student", LoginMode.student),
                          _buildModeTab("Admin / Lead", LoginMode.admin),
                          _buildModeTab("Guest", LoginMode.external),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: TextField(
                            controller: _emailController,
                            cursorColor: const Color(0xFF1D1049),
                            keyboardType: TextInputType.emailAddress,
                            decoration: myDecoration(
                              _selectedMode == LoginMode.student
                                  ? "NITJ Email (@nitj.ac.in)"
                                  : (_selectedMode == LoginMode.admin
                                      ? "Admin / Faculty Email"
                                      : "Guest Email"),
                              Icons.email,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedMode != LoginMode.external)
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _passwordController,
                              cursorColor: const Color(0xFF1D1049),
                              obscureText: _obscurePassword,
                              decoration: myDecoration(
                                "Password",
                                Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              onSubmitted: (_) => _handleLogin(),
                            ),
                          )
                        else
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _otpController,
                              cursorColor: const Color(0xFF1D1049),
                              keyboardType: TextInputType.number,
                              decoration: myDecoration(
                                "6-Digit Access Code / OTP",
                                Icons.vpn_key,
                              ),
                              onSubmitted: (_) => _handleLogin(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF191C32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        minimumSize: const Size.fromHeight(65),
                      ),
                      child: Text(
                        _selectedMode == LoginMode.external ? "LOGIN WITH OTP" : "LOGIN",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedMode != LoginMode.external)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordRollScreen()),
                          );
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
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "DON'T HAVE AN ACCOUNT? REGISTER",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
      ),
    );
  }

  Widget _buildModeTab(String title, LoginMode mode) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF191C32) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration myDecoration(String hintText, IconData youricon, {Widget? suffixIcon}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 20),
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFDEF5E9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        youricon,
        size: 18,
        color: const Color(0xFF5FC88F),
      ),
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
