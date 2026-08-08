import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/models/user_model.dart';
import 'login_screen.dart';
import 'package:xplore_app/config/theme.dart';

class UserProfileScreen extends StatelessWidget {
  final Function(int) changeindex;
  const UserProfileScreen({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    final name = currentUser?.name ?? "XYZ ABC";
    final rollNo = currentUser?.rollNo ?? "";
    final email = currentUser?.email ?? "";
    final branch = currentUser?.branch ?? "";
    final program = currentUser?.program ?? "";
    final year = currentUser?.year ?? "";

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        backgroundColor: AppColors.scaffoldBackground,
        leading: Row(
          children: [
            const SizedBox(width: 8), // This adds your space on the left
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.cardColor,
              ),
              onPressed: () {
                changeindex(0);
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
                      Container(
                        height: height * 0.8,
                        margin: EdgeInsets.symmetric(
                          horizontal: width * 0.06,
                        ),
                        child: ListView(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: (){}, 
                                  icon: Icon(Icons.edit, size: width * 0.1, color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              controller: TextEditingController(text: rollNo),
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Roll No", Icons.person,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              controller: TextEditingController(text: email),
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Official Email Id", Icons.mail,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              controller: TextEditingController(text: branch),
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Branch", Icons.category,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              controller: TextEditingController(text: program),
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Program", Icons.school,)
                            ),
                            SizedBox(
                              height: height*0.02,
                            ),
                            TextField(
                              controller: TextEditingController(text: year),
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: myDecoration("Year", Icons.calendar_today,)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    "assets/homescreen4.png",
                    width: width*0.4,
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
