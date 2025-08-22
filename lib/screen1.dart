import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xplore_app/Adminpage.dart';
import 'package:xplore_app/screen2.dart';
import './BackendIntegrate/auth_view_model.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  List<bool> _selected = [true, false]; // [Admin, Student]
  
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Validate input
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }
    
    if (_passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter your password');
      return;
    }

    try {
      await authViewModel.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Check if login was successful
      if (authViewModel.isAuthenticated) {
        // Navigate based on user role and toggle selection
        if (_selected[0]) { // Admin selected
          if (authViewModel.currentUser?.role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminPage()),
            );
          } else {
            _showSnackBar('Access denied. Admin privileges required.');
          }
        } else { // Student selected
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminPage()), // Replace with student page
          );
        }
      }
    } catch (e) {
      // Error will be handled by the Consumer widget below
    }
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(246, 247, 250, 1),
        body: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return ListView(
              children: [
                const SizedBox(height: 20),
                // Toggle at top-left
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(30),
                      fillColor: const Color(0xFF7B61FF),
                      selectedColor: Colors.white,
                      color: Colors.black,
                      isSelected: _selected,
                      onPressed: authViewModel.isLoading ? null : (int index) {
                        setState(() {
                          for (int i = 0; i < _selected.length; i++) {
                            _selected[i] = i == index;
                          }
                        });

                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Screen1()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Screen2()),
                          );
                        }
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Admin"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Student"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Image.asset(
                  "assets/screen1.png",
                  height: 330,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "LOGIN",
                      selectionColor: Color(0xFF1D1049),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
                
                // Error message display
                if (authViewModel.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authViewModel.errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => authViewModel.clearError(),
                          child: Icon(Icons.close, color: Colors.red.shade700, size: 18),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        cursorColor: const Color(0xFF1D1049),
                        obscureText: false,
                        enabled: !authViewModel.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        decoration: myDecoration(
                            "Official Email ID", FontAwesomeIcons.envelope),
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFF1D1049),
                        obscureText: true,
                        enabled: !authViewModel.isLoading,
                        decoration: myDecoration("Password", FontAwesomeIcons.lock),
                        onSubmitted: (_) => _handleLogin(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading ? null : _handleLogin,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return const Color(0xFF7B61FF).withOpacity(0.6);
                          }
                          return const Color(0xFF7B61FF);
                        },
                      ),
                      fixedSize: const WidgetStatePropertyAll(Size.fromHeight(55)),
                    ),
                    child: authViewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "LOGIN",
                            selectionColor: Colors.white,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: authViewModel.isLoading ? null : () {
                      _showForgotPasswordDialog();
                    },
                    child: Text(
                      "FORGOT PASSWORD?",
                      style: TextStyle(
                        color: authViewModel.isLoading 
                            ? const Color(0xFF7B61FF).withOpacity(0.6)
                            : const Color(0xFF7B61FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to reset your password:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here you can implement forgot password functionality
                // For now, just show a message
                Navigator.of(context).pop();
                _showSnackBar('Password reset functionality not implemented yet');
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }
}

InputDecoration myDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 20),
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration:
          const BoxDecoration(color: Color(0xFFFFF6DF), shape: BoxShape.circle),
      child: Icon(
        size: 20,
        youricon,
        color: const Color(0xFFFFCA3A),
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