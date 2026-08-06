import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/user/login_screen.dart';

/// Reset-password screen.
/// The user pastes the token from the reset email, then enters a new password.
/// In a deep-link setup the [token] would be passed from the URL; for now the
/// user enters it manually (a common approach when deep linking isn't configured).
class ResetPasswordScreen extends StatefulWidget {
  /// Raw reset token from the email link.  Null means user must type it.
  final String? token;

  const ResetPasswordScreen({super.key, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _tokenController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.token ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleReset() {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (token.isEmpty) {
      _showSnackBar('Please enter the reset token from your email');
      return;
    }
    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      _showSnackBar('Passwords do not match');
      return;
    }

    context
        .read<AuthBloc>()
        .add(ResetPasswordRequested(token: token, newPassword: password));
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSuccess) {
          _showSnackBar('Password reset! Please log in.', color: Colors.green);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          _showSnackBar(state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(builder: (context, constraints) {
          final double height = constraints.maxHeight;
          final bool isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFFE3C9), Color(0xFFD299B8)],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Image.asset(
                  "assets/newpass.png",
                  height: isPortrait ? height * 0.30 : height * 0.5,
                ),
                SizedBox(height: height * 0.04),
                // Only show token field when token wasn't passed via deep link
                if (widget.token == null)
                  _buildField(_tokenController, 'Paste reset token from email',
                      Icons.key, false),
                SizedBox(height: height * 0.01),
                _buildField(
                    _passwordController, 'New Password', Icons.lock, true),
                SizedBox(height: height * 0.01),
                _buildField(
                    _confirmController, 'Confirm Password', Icons.lock, true),
                SizedBox(height: height * 0.06),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed:
                            state is AuthLoading ? null : _handleReset,
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
                                'RESET PASSWORD',
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

  Widget _buildField(TextEditingController controller, String hint,
      IconData icon, bool obscure) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Color(0xFFEBECFF), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Color(0xFF9F9DF3)),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
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
      ),
    );
  }
}
