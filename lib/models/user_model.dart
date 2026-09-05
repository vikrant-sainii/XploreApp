import 'club_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? userType; // "student" | "admin" | "external"
  final String? rollNo;
  final String? branch;
  final dynamic year; // string or number from API
  final String? program; // "BTECH" | "MTECH" | "OTHER"
  final String? clubId;
  final String? instagramUrl;
  final String? linkedInUrl;
  final String? twitterUrl;
  final String? portfolioUrl;
  final String? whatsappNumber;
  final String? githubUrl;
  final String? profileImage;
  final List<ClubMembershipModel> memberships;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.userType,
    this.rollNo,
    this.branch,
    this.year,
    this.program,
    this.clubId,
    this.instagramUrl,
    this.linkedInUrl,
    this.twitterUrl,
    this.portfolioUrl,
    this.whatsappNumber,
    this.githubUrl,
    this.profileImage,
    this.memberships = const [],
  });

  bool get isClubAccount =>
      (role.toLowerCase() == 'club_account' ||
       userType?.toLowerCase() == 'club_account' ||
       (role.toLowerCase() == 'club' && rollNo == null && program == null)) &&
      !isAdmin;

  bool get isClubHead =>
      isClubAccount ||
      role.toUpperCase() == 'CLUB' ||
      role.toUpperCase() == 'CLUB_HEAD' ||
      memberships.any((m) => m.role.toUpperCase() == 'CLUB_HEAD');

  bool get isFacultyCoordinator =>
      role.toUpperCase() == 'FACULTYCOORDINATOR' ||
      role.toUpperCase() == 'FACULTY_COORDINATOR' ||
      role.toUpperCase() == 'FACULTY';

  bool get isStudentCoordinator =>
      role.toUpperCase() == 'STUDENT_COORDINATOR' ||
      (role.toUpperCase() == 'COORDINATOR' && !isFacultyCoordinator) ||
      memberships.any((m) => m.role.toUpperCase() == 'COORDINATOR' || m.role.toUpperCase() == 'STUDENT_COORDINATOR');

  bool get isCoordinator =>
      isClubHead ||
      isFacultyCoordinator ||
      isStudentCoordinator;

  bool get isAdmin =>
      role.toLowerCase() == 'admin' ||
      role.toLowerCase() == 'platformadmin' ||
      role.toLowerCase() == 'paymentadmin' ||
      userType?.toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<ClubMembershipModel> parsedMemberships = [];
    if (json['memberships'] is List) {
      parsedMemberships = (json['memberships'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => ClubMembershipModel.fromJson(m))
          .toList();
    }

    String? extractedClubId;
    if (json['clubId'] != null) {
      if (json['clubId'] is String) {
        extractedClubId = json['clubId'];
      } else if (json['clubId'] is Map && json['clubId']['id'] != null) {
        extractedClubId = json['clubId']['id'].toString();
      } else if (json['clubId'] is Map && json['clubId']['_id'] != null) {
        extractedClubId = json['clubId']['_id'].toString();
      }
    } else if (json['club_id'] != null) {
      extractedClubId = json['club_id'].toString();
    } else if (json['club'] is Map && json['club']['id'] != null) {
      extractedClubId = json['club']['id'].toString();
    } else if (json['club'] is Map && json['club']['_id'] != null) {
      extractedClubId = json['club']['_id'].toString();
    }

    final String parsedRole = json['role']?.toString() ?? 'member';
    final String parsedUserType = json['userType']?.toString() ?? (parsedRole == 'admin' ? 'admin' : (parsedRole == 'club' ? 'club' : 'student'));

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: parsedRole,
      userType: parsedUserType,
      rollNo: json['rollNo']?.toString(),
      branch: json['branch']?.toString(),
      year: json['year'],
      program: json['program']?.toString(),
      clubId: extractedClubId,
      instagramUrl: json['instagramUrl']?.toString() ?? json['instagram']?.toString(),
      linkedInUrl: json['linkedInUrl']?.toString() ?? json['linkedin']?.toString(),
      twitterUrl: json['twitterUrl']?.toString() ?? json['twitter']?.toString() ?? json['xUrl']?.toString(),
      portfolioUrl: json['portfolioUrl']?.toString() ?? json['portfolio']?.toString() ?? json['website']?.toString(),
      whatsappNumber: json['whatsappNumber']?.toString() ?? json['whatsapp']?.toString(),
      githubUrl: json['githubUrl']?.toString() ?? json['github']?.toString(),
      profileImage: json['profileImage']?.toString() ??
          json['image']?.toString() ??
          json['avatar']?.toString() ??
          json['logo']?.toString() ??
          json['clubLogo']?.toString() ??
          json['photoUrl']?.toString(),
      memberships: parsedMemberships,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (userType != null) 'userType': userType,
      if (rollNo != null) 'rollNo': rollNo,
      if (branch != null) 'branch': branch,
      if (year != null) 'year': year,
      if (program != null) 'program': program,
      if (clubId != null) 'clubId': clubId,
      if (instagramUrl != null) 'instagramUrl': instagramUrl,
      if (linkedInUrl != null) 'linkedInUrl': linkedInUrl,
      if (twitterUrl != null) 'twitterUrl': twitterUrl,
      if (portfolioUrl != null) 'portfolioUrl': portfolioUrl,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      if (githubUrl != null) 'githubUrl': githubUrl,
      if (profileImage != null) 'profileImage': profileImage,
      'memberships': memberships.map((m) => m.toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? userType,
    String? rollNo,
    String? branch,
    dynamic year,
    String? program,
    String? clubId,
    String? instagramUrl,
    String? linkedInUrl,
    String? twitterUrl,
    String? portfolioUrl,
    String? whatsappNumber,
    String? githubUrl,
    String? profileImage,
    List<ClubMembershipModel>? memberships,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      rollNo: rollNo ?? this.rollNo,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      program: program ?? this.program,
      clubId: clubId ?? this.clubId,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      githubUrl: githubUrl ?? this.githubUrl,
      profileImage: profileImage ?? this.profileImage,
      memberships: memberships ?? this.memberships,
    );
  }
}
