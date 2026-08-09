import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/services/user_service.dart';
import 'login_screen.dart';
import 'package:xplore_app/config/theme.dart';

class UserProfileScreen extends StatefulWidget {
  final Function(int) changeindex;
  const UserProfileScreen({super.key, required this.changeindex});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _rollNoController;
  late TextEditingController _branchController;
  late TextEditingController _programController;
  late TextEditingController _yearController;
  
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rollNoController = TextEditingController();
    _branchController = TextEditingController();
    _programController = TextEditingController();
    _yearController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _branchController.dispose();
    _programController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  String _displayYear(String yearVal) {
    if (yearVal == "1") return "1st Year";
    if (yearVal == "2") return "2nd Year";
    if (yearVal == "3") return "3rd Year";
    if (yearVal == "4") return "4th Year";
    return yearVal.isEmpty ? "Not set" : "$yearVal Year";
  }

  Future<void> _saveProfile(UserModel currentUser) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'rollNo': _rollNoController.text.trim(),
        'branch': _branchController.text.trim(),
        'program': _programController.text.trim(),
        'year': _yearController.text.trim(),
      };
      
      final result = await UserService().updateProfile(currentUser.role, currentUser.id, updateData);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );
        context.read<AuthBloc>().add(CheckSession());
        setState(() {
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Failed to update profile")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
      if (!_isInitialized) {
        _nameController.text = currentUser.name;
        _rollNoController.text = currentUser.rollNo ?? "";
        _branchController.text = currentUser.branch ?? "";
        _programController.text = currentUser.program ?? "";
        _yearController.text = currentUser.year ?? "";
        _isInitialized = true;
      }
    }

    final email = currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: AppColors.scaffoldBackground,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.cardColor,
              ),
              onPressed: () {
                widget.changeindex(0);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: IconButton.styleFrom(backgroundColor: AppColors.cardColor),
            color: Colors.white,
          ),
          const Padding(padding: EdgeInsets.all(8))
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Container(
            color: AppColors.scaffoldBackground,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: height * 0.1,
                      left: width * 0.02,
                      right: width * 0.02),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppColors.scaffoldBackground,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.03,
                      ),
                      // Pinned Edit Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                 : TextButton.icon(
                                     onPressed: () {
                                       if (_isEditing) {
                                         if (currentUser != null) {
                                           _saveProfile(currentUser);
                                         }
                                       } else {
                                         setState(() {
                                           _isEditing = true;
                                         });
                                       }
                                     },
                                     icon: Icon(
                                       _isEditing ? Icons.save : Icons.edit,
                                       size: 20,
                                       color: _isEditing ? AppColors.primary : Colors.white,
                                     ),
                                     label: Text(
                                       _isEditing ? "SAVE" : "EDIT",
                                       style: TextStyle(
                                         color: _isEditing ? AppColors.primary : Colors.white,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ),
                          ],
                        ),
                      ),
                      // Pinned Name
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                        child: Text(
                          _nameController.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Scrollable fields
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width * 0.06,
                          ),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              SizedBox(
                              height: height * 0.02,
                            ),
                              TextField(
                                controller: _nameController,
                                readOnly: !_isEditing,
                                style: const TextStyle(color: Colors.white),
                                decoration: myDecoration("Full Name", Icons.person_outline),
                                onChanged: (val) => setState(() {}),
                              ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            TextField(
                              controller: _rollNoController,
                              readOnly: !_isEditing,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Roll No", Icons.assignment_ind_outlined),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            TextField(
                              controller: TextEditingController(text: email),
                              readOnly: true,
                              style: const TextStyle(color: Colors.white70),
                              decoration: myDecoration("Official Email Id (Read-only)", Icons.mail_outline),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            TextField(
                              controller: _branchController,
                              readOnly: !_isEditing,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Branch", Icons.category_outlined),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            TextField(
                              controller: _programController,
                              readOnly: !_isEditing,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Program", Icons.school_outlined),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            _isEditing
                                ? SizedBox(
                                    height: 55,
                                    child: DropdownButtonFormField<String>(
                                      value: _yearController.text.isNotEmpty ? _yearController.text : null,
                                      dropdownColor: AppColors.cardColor,
                                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                      style: const TextStyle(color: Colors.white, fontSize: 15),
                                      decoration: myDecoration("Year", Icons.calendar_today_outlined),
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
                                  )
                                : TextField(
                                    controller: TextEditingController(text: _displayYear(_yearController.text)),
                                    readOnly: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: myDecoration("Year", Icons.calendar_today_outlined),
                                  ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    "assets/homescreen4.png",
                    width: width * 0.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

InputDecoration myDecoration(String hintText, IconData youricon) {
  return InputDecoration(
    labelText: hintText,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
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
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
