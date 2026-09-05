import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/services/api_config.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String _selectedProgram = 'BTECH';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNoController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final rollNo = _rollNoController.text.trim();
    final branch = _branchController.text.trim();
    final year = int.tryParse(_yearController.text.trim()) ?? 1;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name"), backgroundColor: Colors.red),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedProgram != 'OTHER' && !email.endsWith('@nitj.ac.in')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Students must register with official @nitj.ac.in email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedProgram == 'OTHER') {
      context.read<AuthBloc>().add(RegisterExternalRequested(name, email));
    } else {
      context.read<AuthBloc>().add(RegisterStudentRequested(
            name: name,
            email: email,
            password: password,
            program: _selectedProgram,
            rollNo: rollNo.isNotEmpty ? rollNo : null,
            branch: branch.isNotEmpty ? branch : null,
            year: year,
          ));
    }
  }

  void _showVerificationSentDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFDEF5E9),
              child: Icon(Icons.mark_email_read, color: Color(0xFF5FC88F), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Account Created! 📩",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF191C32)),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Redirect back to LoginScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("PROCEED TO LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isStudent = _selectedProgram != 'OTHER';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const UserPortalScreen()),
            (route) => false,
          );
        } else if (state is RegisterSuccess) {
          _showVerificationSentDialog(state.message);
        } else if (state is AuthPasswordResetSuccess) {
          _showVerificationSentDialog(state.message);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            final bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF816174), Color(0xFFF3E7EF)],
                ),
              ),
              child: Stack(
                children: [
                  ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                iconSize: 20,
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.black),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                iconSize: 20,
                                onPressed: () => ApiConfig.showServerConfigDialog(context),
                                icon: const Icon(Icons.settings, color: Color(0xFFF7931A)),
                                tooltip: "Server Settings",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        "assets/screen2.png",
                        height: isPortrait ? height * 0.22 : height * 0.35,
                      ),
                      const Text(
                        "REGISTER",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Create your ClubSetu account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: myDecoration("Full Name", Icons.person),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedProgram,
                              decoration: myDecoration("Degree Program", Icons.school),
                              items: const [
                                DropdownMenuItem(value: "BTECH", child: Text("B.Tech (NITJ)")),
                                DropdownMenuItem(value: "MTECH", child: Text("M.Tech (NITJ)")),
                                DropdownMenuItem(value: "MBA", child: Text("MBA (NITJ)")),
                                DropdownMenuItem(value: "MSC", child: Text("M.Sc (NITJ)")),
                                DropdownMenuItem(value: "PHD", child: Text("PhD (NITJ)")),
                                DropdownMenuItem(value: "OTHER", child: Text("External / Other")),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedProgram = val);
                              },
                            ),
                            const SizedBox(height: 10),
                            if (isStudent) ...[
                              TextField(
                                controller: _rollNoController,
                                keyboardType: TextInputType.number,
                                decoration: myDecoration("Roll Number (e.g. 21103045)", Icons.badge),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _branchController,
                                      decoration: myDecoration("Branch (CSE, IT)", Icons.account_tree),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: _yearController,
                                      keyboardType: TextInputType.number,
                                      decoration: myDecoration("Year", Icons.calendar_today),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: myDecoration(
                                isStudent ? "Official Email (@nitj.ac.in)" : "Email Address",
                                Icons.email,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passwordController,
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
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF191C32),
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                          ),
                          child: const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191C32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return Container(
                          color: Colors.black26,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
