import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';
import 'package:xplore_app/config/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    _programController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    context.read<AuthBloc>().add(RegisterRequested(
          name: _nameController.text,
          rollNo: _rollNoController.text,
          branch: _branchController.text,
          year: _yearController.text,
          program: _programController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ));
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
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else if (state is Authenticated) {
            // Dev-mode: backend auto-logged us in
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserPortalScreen()),
            );
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
                      height: 120,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "REGISTER",
                          selectionColor: AppColors.primary,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 55,
                            child: TextField(
                              controller: _nameController,
                              cursorColor: AppColors.primary,
                              decoration: myDecoration(
                                  "Full Name", FontAwesomeIcons.user),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 55,
                            child: TextField(
                              controller: _rollNoController,
                              cursorColor: AppColors.primary,
                              decoration: myDecoration(
                                  "Roll Number", FontAwesomeIcons.idCard),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 55,
                                  child: TextField(
                                    controller: _branchController,
                                    cursorColor: AppColors.primary,
                                    decoration: myDecoration(
                                        "Branch", FontAwesomeIcons.codeBranch),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                               Expanded(
                                child: SizedBox(
                                  height: 55,
                                  child: DropdownButtonFormField<String>(
                                    value: _yearController.text.isNotEmpty ? _yearController.text : null,
                                    dropdownColor: AppColors.cardColor,
                                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                    decoration: myDecoration("Year", FontAwesomeIcons.calendar),
                                    items: const [
                                      DropdownMenuItem(value: "1", child: Text("1st")),
                                      DropdownMenuItem(value: "2", child: Text("2nd")),
                                      DropdownMenuItem(value: "3", child: Text("3rd")),
                                      DropdownMenuItem(value: "4", child: Text("4th")),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _yearController.text = val ?? "";
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 55,
                            child: TextField(
                              controller: _programController,
                              cursorColor: AppColors.primary,
                              decoration: myDecoration("Program (e.g. BTECH)",
                                  FontAwesomeIcons.graduationCap),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 55,
                            child: TextField(
                              controller: _emailController,
                              cursorColor: AppColors.primary,
                              keyboardType: TextInputType.emailAddress,
                              decoration: myDecoration("Official Email ID",
                                  FontAwesomeIcons.envelope),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 55,
                            child: TextField(
                              controller: _passwordController,
                              cursorColor: AppColors.primary,
                              obscureText: true,
                              decoration:
                                  myDecoration("Password", FontAwesomeIcons.lock),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: const Text(
                          "REGISTER",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: const Text(
                          "ALREADY HAVE AN ACCOUNT? LOGIN",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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

InputDecoration myDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 20),
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        size: 20,
        youricon,
        color: AppColors.primary,
      ),
    ),
    filled: true,
    fillColor: AppColors.cardColor,
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.textSecondary),
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
