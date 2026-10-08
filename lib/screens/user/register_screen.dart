import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/screens/user/login_screen.dart';
import 'package:xplore_app/screens/user/user_portal_screen.dart';

enum RegisterMode { student, faculty, external }

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
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  RegisterMode _currentMode = RegisterMode.student;
  String _selectedProgram = 'BTECH';
  String? _selectedBranch;
  String? _selectedGradYear;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  // Map of program -> list of {value: API code, label: display name}
  final Map<String, List<Map<String, String>>> _branchesPerProgram = {
    'BTECH': [
      {'value': 'CSE', 'label': 'Computer Science & Engg (CSE)'},
      {'value': 'IT', 'label': 'Information Technology (IT)'},
      {'value': 'ECE', 'label': 'Electronics & Comm (ECE)'},
      {'value': 'EE', 'label': 'Electrical Engg (EE)'},
      {'value': 'ME', 'label': 'Mechanical Engg (ME)'},
      {'value': 'CE', 'label': 'Civil Engg (CE)'},
      {'value': 'ICE', 'label': 'Instrumentation & Control (ICE)'},
      {'value': 'CHE', 'label': 'Chemical Engg (CHE)'},
      {'value': 'TT', 'label': 'Textile Tech (TT)'},
      {'value': 'BT', 'label': 'Biotech (BT)'},
      {'value': 'IPE', 'label': 'Industrial & Prod (IPE)'},
    ],
    'MTECH': [
      {'value': 'CSE', 'label': 'CSE'},
      {'value': 'VLSI', 'label': 'VLSI Design'},
      {'value': 'Structural Engineering', 'label': 'Structural Engg'},
      {'value': 'Thermal Engineering', 'label': 'Thermal Engg'},
      {'value': 'Control & Automation', 'label': 'Control & Automation'},
      {'value': 'Chemical Engineering', 'label': 'Chemical Engg'},
    ],
    'MBA': [
      {'value': 'Human Resources', 'label': 'Human Resources'},
      {'value': 'Finance', 'label': 'Finance'},
      {'value': 'Marketing', 'label': 'Marketing'},
      {'value': 'Operations', 'label': 'Operations'},
    ],
    'MSC': [
      {'value': 'Physics', 'label': 'Physics'},
      {'value': 'Chemistry', 'label': 'Chemistry'},
      {'value': 'Mathematics', 'label': 'Mathematics'},
    ],
    'PHD': [
      {'value': 'Engineering', 'label': 'Research Scholar - Engineering'},
      {'value': 'Sciences', 'label': 'Research Scholar - Sciences'},
      {'value': 'Humanities', 'label': 'Humanities'},
    ],
    'OTHER': [
      {'value': 'General', 'label': 'External Participant / General'},
    ],
  };

  final List<String> _graduationYears = [
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNoController.dispose();
    _collegeNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showSnackBar("Please enter your full name");
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    if (!_agreedToTerms) {
      _showSnackBar("Please agree to the Terms & Conditions to proceed");
      return;
    }

    if (_currentMode == RegisterMode.student) {
      final rollNo = _rollNoController.text.trim();

      if (rollNo.isEmpty) {
        _showSnackBar("Please enter your Roll Number");
        return;
      }

      if (!email.endsWith('@nitj.ac.in')) {
        _showSnackBar("Students must register with official @nitj.ac.in email");
        return;
      }

      if (password.length < 6) {
        _showSnackBar("Password must be at least 6 characters");
        return;
      }

      final yearNum = int.tryParse(_selectedGradYear ?? '2026') ?? 2026;

      context.read<AuthBloc>().add(RegisterStudentRequested(
            name: name,
            email: email,
            password: password,
            program: _selectedProgram,
            rollNo: rollNo,
            branch: _selectedBranch ?? 'General',
            year: yearNum,
          ));
    } else if (_currentMode == RegisterMode.external) {
      final collegeName = _collegeNameController.text.trim();
      final phone = _phoneController.text.trim();
      final yearNum = int.tryParse(_selectedGradYear ?? '2026');

      context.read<AuthBloc>().add(RegisterExternalRequested(
            name: name,
            email: email,
            password: password.isNotEmpty ? password : null,
            collegeName: collegeName.isNotEmpty ? collegeName : null,
            phone: phone.isNotEmpty ? phone : null,
            program: _selectedProgram,
            year: yearNum,
          ));
    } else {
      // Faculty registration mode
      if (!email.endsWith('@nitj.ac.in')) {
        _showSnackBar("Faculty must register with official @nitj.ac.in email");
        return;
      }

      context.read<AuthBloc>().add(RegisterStudentRequested(
            name: name,
            email: email,
            password: password,
            program: 'FACULTY',
            rollNo: null,
            branch: _selectedBranch ?? 'Faculty',
            year: null,
          ));
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNonEditableFieldsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock,
                            color: Colors.amber.shade900, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Non-Editable Fields",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF191C32),
                            ),
                          ),
                          Text(
                            "NITJian Academic Profile",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.amber.shade900, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "These details cannot be changed after registration.",
                        style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildLockedItem("Roll Number", "Official institute roll number"),
              _buildLockedItem(
                  "College Email", "Official @nitj.ac.in email address"),
              _buildLockedItem(
                  "Academic Program", "Your enrolled degree program"),
              _buildLockedItem(
                  "Branch / Department", "Your assigned department"),
              _buildLockedItem(
                  "Expected Graduation Year", "Your estimated completion year"),
              const SizedBox(height: 16),
              const Text(
                "EDITABLE LATER",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Full Name • Profile Photo • Contact Number • Social Links • Password & 2FA",
                style:
                    TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191C32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text("I Understand",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.redAccent, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Color(0xFF191C32),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              child: Icon(Icons.mark_email_read,
                  color: Color(0xFF5FC88F), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Account Created! 📩",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF191C32)),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black87, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191C32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("PROCEED TO LOGIN",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableBranches =
        _branchesPerProgram[_selectedProgram] ?? _branchesPerProgram['BTECH']!;

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
          _showSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(246, 247, 250, 1),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: IconButton(
                          iconSize: 20,
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentMode == RegisterMode.student
                        ? "NITJ Student Registration"
                        : (_currentMode == RegisterMode.faculty
                            ? "NITJ Faculty Registration"
                            : "External Registration"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1049),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentMode == RegisterMode.student
                        ? "Create your official student account"
                        : "Join Campusnode platform",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  // Full Name *
                  _buildLabel("Full Name *"),
                  SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _nameController,
                      cursorColor: const Color(0xFF1D1049),
                      decoration: myDecoration("e.g Himanshu", Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Student Specific Fields
                  if (_currentMode == RegisterMode.student) ...[
                    _buildLabel("Roll Number *"),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _rollNoController,
                        cursorColor: const Color(0xFF1D1049),
                        keyboardType: TextInputType.number,
                        decoration: myDecoration("e.g. 241050148", Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Program & Branch Dropdowns Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Program *"),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedProgram,
                                isExpanded: true,
                                decoration: myDecoration(
                                    "Select Program", Icons.school),
                                items: const [
                                  DropdownMenuItem(
                                      value: "BTECH",
                                      child: Text("B.Tech",
                                          overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(
                                      value: "MTECH",
                                      child: Text("M.Tech",
                                          overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(
                                      value: "MBA",
                                      child: Text("MBA",
                                          overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(
                                      value: "MSC",
                                      child: Text("M.Sc",
                                          overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(
                                      value: "PHD",
                                      child: Text("PhD",
                                          overflow: TextOverflow.ellipsis)),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedProgram = val;
                                      _selectedBranch = null;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Branch *"),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedBranch,
                                isExpanded: true,
                                hint: const Text("Select branch",
                                    style: TextStyle(fontSize: 13)),
                                decoration: myDecoration(
                                    "Select Branch", Icons.account_tree),
                                items: availableBranches
                                    .map((b) => DropdownMenuItem(
                                          value: b['value']!,
                                          child: Text(
                                            b['label']!,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedBranch = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildLabel("Expected Graduation Year *"),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGradYear,
                      isExpanded: true,
                      hint: const Text("Select Graduation Year",
                          style: TextStyle(fontSize: 13)),
                      decoration: myDecoration(
                          "Select Graduation Year", Icons.calendar_today),
                      items: _graduationYears
                          .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedGradYear = val),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // External Specific Fields
                  if (_currentMode == RegisterMode.external) ...[
                    _buildLabel("College / Organization Name *"),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _collegeNameController,
                        cursorColor: const Color(0xFF1D1049),
                        decoration: myDecoration(
                            "e.g. IIT Delhi / XYZ College", Icons.business),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildLabel("Contact Phone Number"),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _phoneController,
                        cursorColor: const Color(0xFF1D1049),
                        keyboardType: TextInputType.phone,
                        decoration:
                            myDecoration("e.g. +91 9876543210", Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Email Field
                  _buildLabel(_currentMode == RegisterMode.external
                      ? "Email Address *"
                      : "College Email *"),
                  SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _emailController,
                      cursorColor: const Color(0xFF1D1049),
                      keyboardType: TextInputType.emailAddress,
                      decoration: myDecoration(
                        _currentMode == RegisterMode.external
                            ? "e.g. your.email@domain.com"
                            : "e.g. @nitj.ac.in",
                        Icons.email,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password Field
                  _buildLabel("Password *"),
                  SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _passwordController,
                      cursorColor: const Color(0xFF1D1049),
                      obscureText: _obscurePassword,
                      decoration: myDecoration(
                        "Create a secure password",
                        Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Terms & Conditions + Non-editable fields box
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              activeColor: const Color(0xFF191C32),
                              onChanged: (val) =>
                                  setState(() => _agreedToTerms = val ?? false),
                            ),
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text("I agree to the ",
                                      style: TextStyle(fontSize: 13)),
                                  GestureDetector(
                                    onTap: () {
                                      _showNonEditableFieldsDialog();
                                    },
                                    child: const Text(
                                      "Terms & Conditions ",
                                      style: TextStyle(
                                        color: Color(0xFF0088FF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline,
                                  size: 18, color: Colors.grey),
                              onPressed: _showNonEditableFieldsDialog,
                            ),
                          ],
                        ),
                        if (_currentMode == RegisterMode.student) ...[
                          const Divider(height: 1),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _showNonEditableFieldsDialog,
                            child: Row(
                              children: const [
                                SizedBox(width: 8),
                                Icon(Icons.lock_outline,
                                    size: 15, color: Color(0xFF0088FF)),
                                SizedBox(width: 6),
                                Text(
                                  "Non-editable fields (5)",
                                  style: TextStyle(
                                    color: Color(0xFF0088FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191C32),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Footer Navigation Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ",
                          style: TextStyle(fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191C32),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _currentMode = RegisterMode.faculty),
                        child: Text(
                          "Register as Faculty",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _currentMode == RegisterMode.faculty
                                ? const Color(0xFF191C32)
                                : Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text("  •  ",
                          style: TextStyle(color: Colors.black38)),
                      GestureDetector(
                        onTap: () => setState(
                            () => _currentMode = RegisterMode.external),
                        child: Text(
                          "Register as External",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _currentMode == RegisterMode.external
                                ? const Color(0xFF191C32)
                                : Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      if (_currentMode != RegisterMode.student) ...[
                        const Text("  •  ",
                            style: TextStyle(color: Colors.black38)),
                        GestureDetector(
                          onTap: () => setState(
                              () => _currentMode = RegisterMode.student),
                          child: const Text(
                            "Student Reg",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191C32),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
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
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Colors.black87,
        ),
      ),
    );
  }
}
