import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/user/login_screen.dart';

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
              const SnackBar(
                content: Text("Registration Successful! Please login."),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Go back to login screen
          } else if (state is AuthError) {
            _showSnackBar(state.message);
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: const Color.fromRGBO(246, 247, 250, 1),
            body: Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      "assets/screen2.png",
                      height: 150,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "REGISTER",
                          selectionColor: Color(0xFF1D1049),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _nameController,
                              cursorColor: const Color(0xFF1D1049),
                              decoration: myDecoration(
                                  "Full Name", FontAwesomeIcons.user),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _rollNoController,
                              cursorColor: const Color(0xFF1D1049),
                              decoration: myDecoration(
                                  "Roll Number", FontAwesomeIcons.idCard),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    controller: _branchController,
                                    cursorColor: const Color(0xFF1D1049),
                                    decoration: myDecoration(
                                        "Branch", FontAwesomeIcons.codeBranch),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    controller: _yearController,
                                    cursorColor: const Color(0xFF1D1049),
                                    decoration: myDecoration(
                                        "Year", FontAwesomeIcons.calendar),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _programController,
                              cursorColor: const Color(0xFF1D1049),
                              decoration: myDecoration("Program (e.g. BTECH)",
                                  FontAwesomeIcons.graduationCap),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _emailController,
                              cursorColor: const Color(0xFF1D1049),
                              keyboardType: TextInputType.emailAddress,
                              decoration: myDecoration("Official Email ID",
                                  FontAwesomeIcons.envelope),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            cursorColor: const Color(0xFF1D1049),
                            obscureText: true,
                            decoration:
                                myDecoration("Password", FontAwesomeIcons.lock),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(const Color(0xFF191C32)),
                          fixedSize:
                              const WidgetStatePropertyAll(Size.fromHeight(65)),
                        ),
                        child: const Text(
                          "REGISTER",
                          selectionColor: Colors.white,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: const Text(
                          "ALREADY HAVE AN ACCOUNT? LOGIN",
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
                // Loading indicator overlay
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Container(
                        color: Colors.black.withOpacity(0.3),
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
