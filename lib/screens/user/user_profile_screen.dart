import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/auth/auth_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/services/club_service.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Function(int) changeindex;
  const UserProfileScreen({super.key, required this.changeindex});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();

  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
    context.read<ClubBloc>().add(FetchAllClubs());
  }

  void _populateFields([ClubModel? matchedClub, bool force = false]) {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      final user = state.user;
      if (force || !_isEditing) {
        _nameController.text = user.name;
        _rollNoController.text = user.rollNo ?? "";
        _emailController.text = user.email;
        _branchController.text = user.branch ?? "";
        _yearController.text = user.year?.toString() ?? "";
        _programController.text = user.program ?? "";

        if (user.profileImage != null && user.profileImage!.isNotEmpty) {
          _logoController.text = user.profileImage!;
        } else if (matchedClub?.image != null && matchedClub!.image!.isNotEmpty) {
          _logoController.text = matchedClub.image!;
        }

        _instagramController.text = user.instagramUrl ?? "";
        _linkedInController.text = user.linkedInUrl ?? "";
        _twitterController.text = user.twitterUrl ?? "";
        _portfolioController.text = user.portfolioUrl ?? "";
        _whatsappController.text = user.whatsappNumber ?? "";
        _githubController.text = user.githubUrl ?? "";
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _emailController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    _programController.dispose();
    _logoController.dispose();
    _instagramController.dispose();
    _linkedInController.dispose();
    _twitterController.dispose();
    _portfolioController.dispose();
    _whatsappController.dispose();
    _githubController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  void _handleSaveProfile(UserModel? user, ClubModel? matchedClub) async {
    final updatedData = {
      'name': _nameController.text.trim(),
      'branch': _branchController.text.trim(),
      'year': int.tryParse(_yearController.text.trim()) ?? 1,
      'instagramUrl': _instagramController.text.trim(),
      'linkedInUrl': _linkedInController.text.trim(),
      'twitterUrl': _twitterController.text.trim(),
      'portfolioUrl': _portfolioController.text.trim(),
      'whatsappNumber': _whatsappController.text.trim(),
      'githubUrl': _githubController.text.trim(),
      'profileImage': _logoController.text.trim(),
      'clubLogo': _logoController.text.trim(),
    };
    if (user != null) {
      context.read<AuthBloc>().add(UpdateProfileRequested(updatedData));
    }

    final clubId = user?.clubId ?? matchedClub?.id;
    if (user != null && (user.isClubAccount || clubId != null)) {
      try {
        final updateClubPayload = <String, dynamic>{
          'name': _nameController.text.trim(),
          'clubName': _nameController.text.trim(),
          if (_logoController.text.isNotEmpty) 'clubLogo': _logoController.text.trim(),
          if (_logoController.text.isNotEmpty) 'image': _logoController.text.trim(),
          'socialLinks': [
            if (_instagramController.text.isNotEmpty) {'platform': 'instagram', 'url': _instagramController.text.trim()},
            if (_linkedInController.text.isNotEmpty) {'platform': 'linkedin', 'url': _linkedInController.text.trim()},
            if (_twitterController.text.isNotEmpty) {'platform': 'twitter', 'url': _twitterController.text.trim()},
            if (_portfolioController.text.isNotEmpty) {'platform': 'website', 'url': _portfolioController.text.trim()},
            if (_whatsappController.text.isNotEmpty) {'platform': 'whatsapp', 'url': _whatsappController.text.trim()},
            if (_githubController.text.isNotEmpty) {'platform': 'github', 'url': _githubController.text.trim()},
          ],
        };
        if (clubId != null && clubId.isNotEmpty) {
          await ClubService().updateClub(clubId, updateClubPayload);
          if (mounted) {
            context.read<ClubBloc>().add(FetchAllClubs());
          }
        }
      } catch (_) {}
    }

    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile details saved successfully!"), backgroundColor: Colors.green),
      );
    }
  }

  void _showUpdateLogoDialog(UserModel? user, ClubModel? matchedClub) {
    final logoTextController = TextEditingController(text: _logoController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Update Club / Profile Logo", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter image URL or asset path (e.g. assets/gdgc.png):", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: logoTextController,
              decoration: myProfileDecoration("Logo Image URL", Icons.image_outlined, hintText: "assets/gdgc.png or https://..."),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newLogo = logoTextController.text.trim();
              Navigator.pop(ctx);
              setState(() {
                _logoController.text = newLogo;
              });
              _handleSaveProfile(user, matchedClub);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF191C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Save Logo", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _currentPassController.clear();
    _newPassController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final current = _currentPassController.text;
              final newPass = _newPassController.text;
              if (current.isNotEmpty && newPass.length >= 6) {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(ChangePasswordRequested(current, newPass));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Updating password..."), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF191C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is Authenticated) {
          _populateFields(null, true);
        }
      },
      builder: (context, state) {
        UserModel? user;
        if (state is Authenticated) {
          user = state.user;
        }

        List<ClubModel> allClubs = [];
        final clubState = context.watch<ClubBloc>().state;
        if (clubState is ClubsLoaded) {
          allClubs = clubState.allClubs.isNotEmpty ? clubState.allClubs : clubState.clubs;
        }

        ClubModel? matchedClub;
        final currentUser = user;
        if (currentUser != null) {
          matchedClub = allClubs.where((c) {
            if (currentUser.clubId != null && currentUser.clubId == c.id) return true;
            if (c.name.toLowerCase().trim() == currentUser.name.toLowerCase().trim()) return true;
            if (c.clubEmail != null && c.clubEmail!.toLowerCase().trim() == currentUser.email.toLowerCase().trim()) return true;
            return false;
          }).firstOrNull;
        }

        _populateFields(matchedClub);

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leadingWidth: 60,
            backgroundColor: const Color(0xFFF3E7EF),
            leading: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  iconSize: 24,
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    widget.changeindex(0);
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                iconSize: 22,
                icon: const Icon(Icons.lock_reset),
                tooltip: "Change Password",
                onPressed: _showChangePasswordDialog,
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              IconButton(
                iconSize: 22,
                icon: const Icon(Icons.logout),
                tooltip: "Logout",
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              return Container(
                color: const Color(0xFFF3E7EF),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: height * 0.08,
                        left: width * 0.02,
                        right: width * 0.02,
                      ),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.02),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                              child: ListView(
                                padding: const EdgeInsets.only(bottom: 120),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFFF3E7EF),
                                        child: IconButton(
                                          onPressed: () {
                                            if (_isEditing) {
                                              setState(() {
                                                _isEditing = false;
                                                _populateFields(matchedClub, true);
                                              });
                                            } else {
                                              setState(() => _isEditing = true);
                                            }
                                          },
                                          icon: Icon(
                                            _isEditing ? Icons.check : Icons.edit,
                                            color: const Color(0xFF191C32),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.name ?? "Profile",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      letterSpacing: -0.5,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color: Color(0xFF191C32),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (user?.isClubAccount == true
                                            ? "OFFICIAL CLUB ACCOUNT"
                                            : (user?.role ?? "MEMBER"))
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFF7931A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Academic / Account Summary Card
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7FA),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user?.isClubAccount == true ? "ACCOUNT TYPE" : "ROLL NO",
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                              ),
                                              Text(
                                                user?.rollNo ?? (user?.isClubAccount == true ? "CLUB ID" : "24103165"),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF191C32)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("EMAIL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              Text(
                                                user?.email ?? "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF191C32)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("PROGRAM & BRANCH", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              Text("${user?.program ?? 'BTECH'} • ${user?.branch ?? 'cse'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF191C32))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Full Name
                                  TextField(
                                    controller: _nameController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("Full Name", Icons.badge, hintText: "VIKRANT"),
                                  ),
                                  const SizedBox(height: 12),

                                  // Instagram URL
                                  TextField(
                                    controller: _instagramController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("Instagram URL", Icons.camera_alt_outlined, hintText: "https://instagram.com/handle"),
                                  ),
                                  const SizedBox(height: 12),

                                  // LinkedIn URL
                                  TextField(
                                    controller: _linkedInController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("LinkedIn URL", Icons.business_center_outlined, hintText: "https://linkedin.com/company/handle"),
                                  ),
                                  const SizedBox(height: 12),

                                  // X (Twitter) URL
                                  TextField(
                                    controller: _twitterController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("X (Twitter) URL", Icons.alternate_email, hintText: "https://x.com/handle"),
                                  ),
                                  const SizedBox(height: 12),

                                  // Portfolio Website
                                  TextField(
                                    controller: _portfolioController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("Portfolio Website", Icons.language, hintText: "https://yourclub.org"),
                                  ),
                                  const SizedBox(height: 12),

                                  // WhatsApp Number / Group
                                  TextField(
                                    controller: _whatsappController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("WhatsApp Number / Group", Icons.phone_android, hintText: "+91 98765 43210"),
                                  ),
                                  const SizedBox(height: 12),

                                  // GitHub URL
                                  TextField(
                                    controller: _githubController,
                                    enabled: _isEditing,
                                    decoration: myProfileDecoration("GitHub URL", Icons.code, hintText: "https://github.com/club-or-user"),
                                  ),

                                  const SizedBox(height: 24),

                                  if (_isEditing)
                                    ElevatedButton(
                                      onPressed: () => _handleSaveProfile(user, matchedClub),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF7931A),
                                        minimumSize: const Size.fromHeight(55),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      ),
                                      child: const Text(
                                        "SAVE PROFILE DETAILS",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Builder(
                        builder: (ctx) {
                          String? resolvedLogo;
                          if (_logoController.text.trim().isNotEmpty) {
                            resolvedLogo = _logoController.text.trim();
                          } else {
                            final currentUser = user;
                            if (currentUser != null) {
                              if (currentUser.profileImage != null && currentUser.profileImage!.isNotEmpty) {
                                resolvedLogo = currentUser.profileImage;
                              }

                              if ((resolvedLogo == null || resolvedLogo.isEmpty) && matchedClub != null && matchedClub.image != null && matchedClub.image!.isNotEmpty) {
                                resolvedLogo = matchedClub.image;
                              }

                              if (resolvedLogo == null || resolvedLogo.isEmpty) {
                                final String nameLower = currentUser.name.toLowerCase();
                                final String emailLower = currentUser.email.toLowerCase();

                                if (nameLower.contains('ladc') || emailLower.contains('ladc')) {
                                  resolvedLogo = 'assets/gdgc.png';
                                } else if (nameLower.contains('gdgc') || emailLower.contains('gdgc')) {
                                  resolvedLogo = 'assets/gdgc.png';
                                } else if (nameLower.contains('octave') || emailLower.contains('octave')) {
                                  resolvedLogo = 'assets/octave.png';
                                } else if (nameLower.contains('bhangra') || emailLower.contains('bhangra')) {
                                  resolvedLogo = 'assets/bhangralogo.png';
                                } else if (currentUser.isClubAccount) {
                                  resolvedLogo = 'assets/gdgc.png';
                                }
                              }
                            }
                          }

                          Widget avatarChild;
                          if (resolvedLogo != null && resolvedLogo.isNotEmpty) {
                            avatarChild = Container(
                              width: width * 0.32,
                              height: width * 0.32,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.14),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: const Color(0xFFFFEBE4),
                                backgroundImage: resolvedLogo.startsWith('http')
                                    ? NetworkImage(resolvedLogo) as ImageProvider
                                    : AssetImage(resolvedLogo),
                              ),
                            );
                          } else {
                            avatarChild = Image.asset(
                              "assets/homescreen4.png",
                              width: width * 0.35,
                            );
                          }

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              avatarChild,
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _showUpdateLogoDialog(user, matchedClub),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF191C32),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

InputDecoration myProfileDecoration(String labelText, IconData youricon, {String? hintText}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFFA0A3BD), fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Color(0xFFFFEBE4), shape: BoxShape.circle),
      child: Icon(
        youricon,
        size: 18,
        color: const Color(0xFFF7931A),
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFF191C32), width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
  );
}
