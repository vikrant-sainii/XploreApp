import 'package:equatable/equatable.dart';

class ClubMembershipModel extends Equatable {
  final String id;
  final String clubId;
  final String? clubName;
  final String? studentId;
  final String role; // "CLUB_HEAD" | "COORDINATOR" | "MEMBER"
  final bool canTakeAttendance;
  final bool canEditEvents;
  final bool canViewDashboard;
  final bool canCheckRegistration;
  final Map<String, dynamic>? student;

  const ClubMembershipModel({
    required this.id,
    required this.clubId,
    this.clubName,
    this.studentId,
    required this.role,
    this.canTakeAttendance = false,
    this.canEditEvents = false,
    this.canViewDashboard = false,
    this.canCheckRegistration = false,
    this.student,
  });

  String get studentName => student?['name']?.toString() ?? 'Student Member';
  String get branch => student?['branch']?.toString() ?? 'Department';
  int get year => (student?['year'] is int) ? student!['year'] as int : 1;

  factory ClubMembershipModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> perms = {};
    if (json['permissions'] is Map) {
      perms = Map<String, dynamic>.from(json['permissions']);
    }

    final roleStr = (json['role'] ?? 'MEMBER').toString().toUpperCase();

    return ClubMembershipModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      clubName: json['clubName']?.toString(),
      studentId: json['studentId']?.toString(),
      role: roleStr,
      canTakeAttendance: json['canTakeAttendance'] == true ||
          perms['canTakeAttendance'] == true ||
          roleStr == 'CLUB_HEAD' ||
          roleStr == 'COORDINATOR',
      canEditEvents: json['canEditEvents'] == true ||
          perms['canEditEvents'] == true ||
          roleStr == 'CLUB_HEAD' ||
          roleStr == 'COORDINATOR',
      canViewDashboard: perms['canViewDashboard'] == true ||
          roleStr == 'CLUB_HEAD' ||
          roleStr == 'COORDINATOR',
      canCheckRegistration: perms['canCheckRegistration'] == true ||
          roleStr == 'CLUB_HEAD' ||
          roleStr == 'COORDINATOR',
      student: json['student'] is Map<String, dynamic> ? json['student'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      if (clubName != null) 'clubName': clubName,
      if (studentId != null) 'studentId': studentId,
      'role': role,
      'canTakeAttendance': canTakeAttendance,
      'canEditEvents': canEditEvents,
      'permissions': {
        'canTakeAttendance': canTakeAttendance,
        'canEditEvents': canEditEvents,
        'canViewDashboard': canViewDashboard,
        'canCheckRegistration': canCheckRegistration,
      },
      if (student != null) 'student': student,
    };
  }

  @override
  List<Object?> get props => [id, clubId, clubName, studentId, role, canTakeAttendance, canEditEvents];
}

class SocialLinkModel extends Equatable {
  final String? id;
  final String platform;
  final String url;

  const SocialLinkModel({this.id, required this.platform, required this.url});

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    return SocialLinkModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      platform: json['platform']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'platform': platform, 'url': url};

  @override
  List<Object?> get props => [id, platform, url];
}

class ClubModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? category;
  final String? image;
  final String? bannerImage;
  final String? motto;
  final String? mission;
  final String? establishedYear;
  final List<String> studentCoordinators;
  final String? clubEmail;
  final String? facultyEmail;
  final String? facultyName;
  final String? facultyCoordinatorId;
  final Map<String, dynamic>? facultyCoordinator;
  final List<SocialLinkModel> socialLinks;
  final List<String> clubGallery;
  final List<String> clubSponsors;
  final String role; // Helper field for user relation ("HEAD", "COORDINATOR", "MEMBER", or "EXPLORE")

  const ClubModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.category,
    this.image,
    this.bannerImage,
    this.motto,
    this.mission,
    this.establishedYear,
    this.studentCoordinators = const [],
    this.clubEmail,
    this.facultyEmail,
    this.facultyName,
    this.facultyCoordinatorId,
    this.facultyCoordinator,
    this.socialLinks = const [],
    this.clubGallery = const [],
    this.clubSponsors = const [],
    this.role = 'MEMBER',
  });

  String get bannerUrl {
    if (bannerImage != null && bannerImage!.isNotEmpty && bannerImage!.startsWith('http')) {
      return bannerImage!;
    }
    return 'https://i.pinimg.com/736x/1b/9d/95/1b9d953b9eab30ed0f7d2018fdea428e.jpg';
  }

  factory ClubModel.fromJson(Map<String, dynamic> json, {String defaultRole = 'MEMBER'}) {
    List<SocialLinkModel> parsedLinks = [];
    if (json['socialLinks'] is List) {
      parsedLinks = (json['socialLinks'] as List)
          .whereType<Map<String, dynamic>>()
          .map((l) => SocialLinkModel.fromJson(l))
          .toList();
    }

    List<String> gallery = [];
    if (json['clubGallery'] is List) {
      gallery = (json['clubGallery'] as List).map((e) => e.toString()).toList();
    } else if (json['media'] is List) {
      gallery = (json['media'] as List)
          .whereType<Map>()
          .map((m) => m['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }

    List<String> sponsors = [];
    if (json['clubSponsors'] is List) {
      sponsors = (json['clubSponsors'] as List).map((e) => e.toString()).toList();
    } else if (json['sponsors'] is List) {
      sponsors = (json['sponsors'] as List)
          .whereType<Map>()
          .map((s) => s['logoUrl']?.toString() ?? s['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }

    List<String> studentCoords = [];
    if (json['studentCoordinators'] is List) {
      studentCoords = (json['studentCoordinators'] as List).map((e) => e.toString()).toList();
    }

    return ClubModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['clubName']?.toString() ?? json['name']?.toString() ?? 'Club',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'TECH',
      image: json['clubLogo']?.toString() ?? json['image']?.toString(),
      bannerImage: json['bannerImage']?.toString() ?? json['banner']?.toString() ?? json['coverImage']?.toString(),
      motto: json['motto']?.toString(),
      mission: json['mission']?.toString(),
      establishedYear: json['establishedYear']?.toString() ?? json['established']?.toString(),
      studentCoordinators: studentCoords,
      clubEmail: json['clubEmail']?.toString(),
      facultyEmail: json['facultyEmail']?.toString(),
      facultyName: json['facultyName']?.toString(),
      facultyCoordinatorId: json['facultyCoordinatorId']?.toString(),
      facultyCoordinator: json['facultyCoordinator'] is Map<String, dynamic>
          ? json['facultyCoordinator']
          : null,
      socialLinks: parsedLinks,
      clubGallery: gallery,
      clubSponsors: sponsors,
      role: json['role']?.toString() ?? defaultRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubName': name,
      'slug': slug,
      'description': description,
      'category': category,
      'clubLogo': image,
      'clubEmail': clubEmail,
      'facultyEmail': facultyEmail,
      'facultyName': facultyName,
      'socialLinks': socialLinks.map((s) => s.toJson()).toList(),
      'clubGallery': clubGallery,
      'clubSponsors': clubSponsors,
      'role': role,
    };
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? category,
    String? image,
    String? bannerImage,
    String? motto,
    String? mission,
    String? establishedYear,
    List<String>? studentCoordinators,
    String? clubEmail,
    String? facultyEmail,
    String? facultyName,
    String? facultyCoordinatorId,
    Map<String, dynamic>? facultyCoordinator,
    List<SocialLinkModel>? socialLinks,
    List<String>? clubGallery,
    List<String>? clubSponsors,
    String? role,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      bannerImage: bannerImage ?? this.bannerImage,
      motto: motto ?? this.motto,
      mission: mission ?? this.mission,
      establishedYear: establishedYear ?? this.establishedYear,
      studentCoordinators: studentCoordinators ?? this.studentCoordinators,
      clubEmail: clubEmail ?? this.clubEmail,
      facultyEmail: facultyEmail ?? this.facultyEmail,
      facultyName: facultyName ?? this.facultyName,
      facultyCoordinatorId: facultyCoordinatorId ?? this.facultyCoordinatorId,
      facultyCoordinator: facultyCoordinator ?? this.facultyCoordinator,
      socialLinks: socialLinks ?? this.socialLinks,
      clubGallery: clubGallery ?? this.clubGallery,
      clubSponsors: clubSponsors ?? this.clubSponsors,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, description, category, image, role];
}
