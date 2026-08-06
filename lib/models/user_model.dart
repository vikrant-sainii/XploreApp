/// Represents one club membership entry returned by the backend.
class MembershipModel {
  final String clubId;
  final String? clubName;
  final String? slug;
  final String? clubLogo;
  final String role;
  final bool canTakeAttendance;
  final bool canEditEvents;

  const MembershipModel({
    required this.clubId,
    this.clubName,
    this.slug,
    this.clubLogo,
    required this.role,
    required this.canTakeAttendance,
    required this.canEditEvents,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      clubId: json['clubId'] ?? '',
      clubName: json['clubName'],
      slug: json['slug'],
      clubLogo: json['clubLogo'],
      role: json['role'] ?? 'member',
      canTakeAttendance: json['canTakeAttendance'] ?? false,
      canEditEvents: json['canEditEvents'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'clubName': clubName,
        'slug': slug,
        'clubLogo': clubLogo,
        'role': role,
        'canTakeAttendance': canTakeAttendance,
        'canEditEvents': canEditEvents,
      };
}

/// Represents the authenticated user as returned by the backend auth endpoints.
class UserModel {
  final String id;
  final String name;
  final String email;

  /// Top-level role: 'member' | 'club' | 'external' | admin roles
  final String role;

  /// 'student' | 'admin' | 'external'
  final String userType;

  final String? rollNo;
  final String? branch;
  final String? year;
  final String? program;
  final String? clubId;
  final bool isVerified;
  final List<MembershipModel> memberships;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.userType = 'student',
    this.rollNo,
    this.branch,
    this.year,
    this.program,
    this.clubId,
    this.isVerified = false,
    this.memberships = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawMemberships = json['memberships'];
    final memberships = rawMemberships is List
        ? rawMemberships
            .map((m) => MembershipModel.fromJson(m as Map<String, dynamic>))
            .toList()
        : <MembershipModel>[];

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      userType: json['userType'] ?? 'student',
      rollNo: json['rollNo'],
      branch: json['branch'],
      year: json['year'],
      program: json['program'],
      clubId: json['clubId'],
      isVerified: json['isVerified'] ?? false,
      memberships: memberships,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'userType': userType,
        'rollNo': rollNo,
        'branch': branch,
        'year': year,
        'program': program,
        'clubId': clubId,
        'isVerified': isVerified,
        'memberships': memberships.map((m) => m.toJson()).toList(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? userType,
    String? rollNo,
    String? branch,
    String? year,
    String? program,
    String? clubId,
    bool? isVerified,
    List<MembershipModel>? memberships,
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
      isVerified: isVerified ?? this.isVerified,
      memberships: memberships ?? this.memberships,
    );
  }
}
