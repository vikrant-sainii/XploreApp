class CoordinatorModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isTwoStepEnabled;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CoordinatorModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'facultyCoordinator',
    this.isTwoStepEnabled = false,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory CoordinatorModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return CoordinatorModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'facultyCoordinator',
      isTwoStepEnabled: json['isTwoStepEnabled'] == true,
      profileImage: json['profileImage']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  String get displayRole {
    if (role.toLowerCase() == 'facultycoordinator' ||
        role.toLowerCase() == 'faculty_coordinator') {
      return 'FACULTY';
    }
    return role.replaceAll('_', ' ').toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'isTwoStepEnabled': isTwoStepEnabled,
        if (profileImage != null) 'profileImage': profileImage,
      };
}
