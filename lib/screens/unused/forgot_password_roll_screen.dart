import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/config/theme.dart';

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
      _showSnackBar('Please enter your email address', isError: true);
      return;
    }
    context.read<AuthBloc>().add(ForgotPasswordRequested(email));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordLinkSent) {
          _showSnackBar('Reset link sent to your email! Redirecting to Login...');
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        } else if (state is AuthError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardColor,
                  shape: const CircleBorder(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            children: [
              const SizedBox(height: 10),
              Image.asset(
                "assets/screen1.png",
                height: 180,
              ),
              const SizedBox(height: 10),
              const Text(
                "FORGOT PASSWORD",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Enter your registered official email ID below. We'll send you a password reset link directly to your inbox.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                child: TextField(
                  controller: _emailController,
                  cursorColor: AppColors.primary,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputDecoration(
                    "Official Email ID",
                    FontAwesomeIcons.envelope,
                  ),
                  onSubmitted: (_) => _handleForgotPassword(),
                ),
              ),
              const SizedBox(height: 25),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleForgotPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      minimumSize: const Size.fromHeight(60),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "SEND RESET LINK",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "REMEMBER YOUR PASSWORD? LOGIN",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        youricon,
        size: 18,
        color: AppColors.primary,
      ),
    ),
    filled: true,
    fillColor: AppColors.cardColor,
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(color: AppColors.border),
    ),
  );
}
