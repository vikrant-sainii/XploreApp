class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? rollNo;
  final String? branch;
  final String? year;
  final String? program;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.rollNo,
    this.branch,
    this.year,
    this.program,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member', // default role
      rollNo: json['rollNo'],
      branch: json['branch'],
      year: json['year'],
      program: json['program'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'rollNo': rollNo,
      'branch': branch,
      'year': year,
      'program': program,
    };
  }

  // A helper method for creating a copy with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? rollNo,
    String? branch,
    String? year,
    String? program,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      rollNo: rollNo ?? this.rollNo,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      program: program ?? this.program,
    );
  }
}
