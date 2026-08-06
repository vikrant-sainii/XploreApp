import 'package:equatable/equatable.dart';

class FacultyCoordinatorModel extends Equatable {
  final String id;
  final String name;
  final String email;

  const FacultyCoordinatorModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory FacultyCoordinatorModel.fromJson(Map<String, dynamic> json) {
    return FacultyCoordinatorModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, name, email];
}

class ClubModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? category;
  final String? clubLogo;
  final String? facultyName;
  final List<dynamic>? studentCoordinators;
  final FacultyCoordinatorModel? facultyCoordinator;
  final List<FacultyCoordinatorModel> facultyCoordinators;
  final dynamic socialLinks;
  final String? role; // Backward compatibility with previous dummy

  const ClubModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.category,
    this.clubLogo,
    this.facultyName,
    this.studentCoordinators,
    this.facultyCoordinator,
    this.facultyCoordinators = const [],
    this.socialLinks,
    this.role,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    var rawCoordinators = json['facultyCoordinators'] as List?;
    List<FacultyCoordinatorModel> coordinatorsList = rawCoordinators != null
        ? rawCoordinators.map((c) => FacultyCoordinatorModel.fromJson(c)).toList()
        : [];

    return ClubModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['clubName'] ?? json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      category: json['category'],
      clubLogo: json['clubLogo'] ?? json['image'],
      facultyName: json['facultyName'],
      studentCoordinators: json['studentCoordinators'],
      facultyCoordinator: json['facultyCoordinator'] != null
          ? FacultyCoordinatorModel.fromJson(json['facultyCoordinator'])
          : null,
      facultyCoordinators: coordinatorsList,
      socialLinks: json['socialLinks'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubName': name,
      'slug': slug,
      'description': description,
      'category': category,
      'clubLogo': clubLogo,
      'facultyName': facultyName,
      'studentCoordinators': studentCoordinators,
      'facultyCoordinator': facultyCoordinator?.toJson(),
      'facultyCoordinators': facultyCoordinators.map((c) => c.toJson()).toList(),
      'socialLinks': socialLinks,
      'role': role,
    };
  }

  String get image => clubLogo ?? 'assets/gdgc.png'; // fallback asset image if logo is null

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        category,
        clubLogo,
        facultyName,
        studentCoordinators,
        facultyCoordinator,
        facultyCoordinators,
        socialLinks,
        role,
      ];
}
