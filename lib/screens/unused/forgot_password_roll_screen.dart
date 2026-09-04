import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/components/app_primary_button.dart';
import 'package:xplore_app/components/app_text_field.dart';
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
          _showSnackBar(
              'Reset link sent to your email! Redirecting to Login...');
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
              AppTextField(
                controller: _emailController,
                hintText: "Official Email ID",
                prefixIcon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _handleForgotPassword(),
              ),
              const SizedBox(height: 25),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return AppPrimaryButton(
                    onPressed: isLoading ? null : _handleForgotPassword,
                    label: "SEND RESET LINK",
                    loading: isLoading,
                    height: 60,
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
