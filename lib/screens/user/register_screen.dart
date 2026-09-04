import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/components/app_dropdown_field.dart';
import 'package:xplore_app/components/app_primary_button.dart';
import 'package:xplore_app/components/app_text_field.dart';
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
  final TextEditingController _customBranchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedProgram;
  String? _selectedBranch;
  String? _selectedYear;

  static const List<Map<String, String>> _btechBranches = [
    {'code': 'CSE', 'name': 'Computer Science & Engineering'},
    {'code': 'ECE', 'name': 'Electronics & Comm. Engineering'},
    {'code': 'EE', 'name': 'Electrical Engineering'},
    {'code': 'ME', 'name': 'Mechanical Engineering'},
    {'code': 'CE', 'name': 'Civil Engineering'},
    {'code': 'CHE', 'name': 'Chemical Engineering'},
    {'code': 'IPE', 'name': 'Industrial & Production Engg'},
    {'code': 'IT', 'name': 'Information Technology'},
    {'code': 'ICE', 'name': 'Instrumentation & Control Engg'},
    {'code': 'MnC', 'name': 'Mathematics & Computing'},
    {'code': 'DSE', 'name': 'Data Science & Engineering'},
    {'code': 'BT', 'name': 'Biotechnology'},
    {'code': 'TT', 'name': 'Textile Technology'},
  ];

  static const List<Map<String, String>> _mtechBranches = [
    {'code': 'CSE_MTECH', 'name': 'Computer Science and Engineering'},
    {'code': 'VLSI', 'name': 'VLSI Design'},
    {'code': 'SPML', 'name': 'Signal Processing & Machine Learning'},
    {'code': 'AI', 'name': 'Artificial Intelligence'},
    {'code': 'DESIGN', 'name': 'Design Engineering'},
    {'code': 'IS', 'name': 'Intelligent System'},
    {'code': 'MI', 'name': 'Machine Intelligence'},
    {'code': 'SYS', 'name': 'Systems Engineering'},
    {'code': 'DS', 'name': 'Data Science'},
    {'code': 'BT_MTECH', 'name': 'Biotechnology'},
    {'code': 'SCE', 'name': 'Structural & Construction Engg'},
    {'code': 'RE', 'name': 'Renewable Energy'},
    {'code': 'DA', 'name': 'Data Analytics'},
    {'code': 'EVE', 'name': 'Electrical Vehicle Engineering'},
    {'code': 'TEM', 'name': 'Textile Engineering & Management'},
    {'code': 'CSI', 'name': 'Control Systems & Instrumentation'},
    {'code': 'INFOSEC', 'name': 'Information Security'},
    {'code': 'THERMAL', 'name': 'Thermal Engineering'},
    {'code': 'GG', 'name': 'Geotechnical & Geo-environmental Engg'},
    {'code': 'CHE_MTECH', 'name': 'Chemical Engineering'},
    {'code': 'IEDA', 'name': 'Industrial Engg & Data Analytics'},
    {'code': 'MANUF', 'name': 'Manufacturing Technology'},
    {'code': 'ICT', 'name': 'Integrated Circuit Technology'},
    {'code': 'PSE', 'name': 'Power System Engineering'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _customBranchController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final rollNo = _rollNoController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final program = _selectedProgram;

    if (name.isEmpty || rollNo.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all basic details.");
      return;
    }

    if (program == null || program.isEmpty) {
      _showSnackBar("Please select your program.");
      return;
    }

    final branch = program == 'OTHER'
        ? _customBranchController.text.trim()
        : (_selectedBranch ?? '');

    if (branch.isEmpty) {
      _showSnackBar("Please select or enter your branch.");
      return;
    }

    final year = _selectedYear ?? '';
    if (year.isEmpty) {
      _showSnackBar("Please select your passout year.");
      return;
    }

    context.read<AuthBloc>().add(RegisterRequested(
          name: name,
          rollNo: rollNo,
          branch: branch,
          year: year,
          program: program,
          email: email,
          password: password,
        ));
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
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        children: [
                          // 1. Full Name
                          AppTextField(
                            controller: _nameController,
                            hintText: "Full Name",
                            prefixIcon: FontAwesomeIcons.user,
                          ),
                          const SizedBox(height: 8),

                          // 2. Roll Number
                          AppTextField(
                            controller: _rollNoController,
                            hintText: "Roll Number",
                            prefixIcon: FontAwesomeIcons.idCard,
                          ),
                          const SizedBox(height: 8),

                          // 3. Select Program (BTech, MTech, Other)
                          AppDropdownField<String>(
                            value: _selectedProgram,
                            hintText: "Select Program",
                            prefixIcon: FontAwesomeIcons.graduationCap,
                            items: const [
                              DropdownMenuItem(
                                value: "BTECH",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("B.Tech",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "MTECH",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("M.Tech",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "OTHER",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("Other",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedProgram = val;
                                _selectedBranch = null;
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // 4. Select Branch
                          SizedBox(
                            height: 55,
                            child: _selectedProgram == 'OTHER'
                                ? AppTextField(
                                    controller: _customBranchController,
                                    hintText: "Enter Branch Name",
                                    prefixIcon: FontAwesomeIcons.codeBranch,
                                  )
                                : AppDropdownField<String>(
                                    value: _selectedBranch,
                                    hintText: "Select Branch",
                                    prefixIcon: FontAwesomeIcons.codeBranch,
                                    items: _selectedProgram == null
                                        ? null
                                        : (_selectedProgram == 'MTECH'
                                                ? _mtechBranches
                                                : _btechBranches)
                                            .map((b) => DropdownMenuItem(
                                                  value: b['code'],
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4),
                                                    child: Text(
                                                      b['name']!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                    onChanged: _selectedProgram == null
                                        ? null
                                        : (val) {
                                            setState(() {
                                              _selectedBranch = val;
                                            });
                                          },
                                  ),
                          ),
                          const SizedBox(height: 8),

                          // 5. Passout Year Selection
                          AppDropdownField<String>(
                            value: _selectedYear,
                            hintText: "Select Passout Year",
                            prefixIcon: FontAwesomeIcons.calendar,
                            items: const [
                              DropdownMenuItem(
                                value: "2025",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("2025",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "2026",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("2026",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "2027",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("2027",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "2028",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("2028",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "2029",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("2029",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "2030",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("2030",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedYear = val;
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // 5. Email ID
                          AppTextField(
                            controller: _emailController,
                            hintText: "Official Email ID",
                            prefixIcon: FontAwesomeIcons.envelope,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 8),

                          // 6. Password
                          AppTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            prefixIcon: FontAwesomeIcons.lock,
                            obscureText: true,
                            onSubmitted: (_) => _handleRegister(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return AppPrimaryButton(
                            onPressed: _handleRegister,
                            label: "REGISTER",
                            loading: state is AuthLoading,
                            height: 60,
                          );
                        },
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
              ],
            ),
          ),
        ));
  }
}
