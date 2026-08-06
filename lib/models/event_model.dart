import 'package:equatable/equatable.dart';

class EventCreatorModel extends Equatable {
  final String id;
  final String name;

  const EventCreatorModel({
    required this.id,
    required this.name,
  });

  factory EventCreatorModel.fromJson(Map<String, dynamic> json) {
    return EventCreatorModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

class EventClubInfoModel extends Equatable {
  final String id;
  final String name;
  final String? clubLogo;
  final String slug;
  final String? category;

  const EventClubInfoModel({
    required this.id,
    required this.name,
    this.clubLogo,
    required this.slug,
    this.category,
  });

  factory EventClubInfoModel.fromJson(Map<String, dynamic> json) {
    return EventClubInfoModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['clubName'] ?? json['name'] ?? '',
      clubLogo: json['clubLogo'],
      slug: json['slug'] ?? '',
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubName': name,
      'clubLogo': clubLogo,
      'slug': slug,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [id, name, clubLogo, slug, category];
}

class EventModel extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? venue;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? totalSeats;
  final double? entryFee;
  final List<String> allowedPrograms;
  final List<String> allowedYears;
  final List<String> allowedBranches;
  final String? imageUrl;
  final int registeredCount;
  final int views;
  final List<String> waitingListIds;
  final List<String> requiredFields;
  final String? createdById;
  final String? clubId;
  final DateTime? registrationDeadline;
  final String? reviewStatus;
  final List<dynamic>? winners;
  final bool showWinner;
  final bool provideCertificate;
  final String registrationType;
  final int minTeamSize;
  final int maxTeamSize;
  final String paymentMethod;
  final double registrationFee;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EventCreatorModel? createdBy;
  final EventClubInfoModel? club;

  // Backward compatibility with previous dummy fields
  final String? subtitle;
  final String? imageLocation;
  final bool isRegistered;

  const EventModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.venue,
    this.startTime,
    this.endTime,
    this.totalSeats,
    this.entryFee,
    this.allowedPrograms = const [],
    this.allowedYears = const [],
    this.allowedBranches = const [],
    this.imageUrl,
    this.registeredCount = 0,
    this.views = 0,
    this.waitingListIds = const [],
    this.requiredFields = const [],
    this.createdById,
    this.clubId,
    this.registrationDeadline,
    this.reviewStatus,
    this.winners,
    this.showWinner = false,
    this.provideCertificate = false,
    this.registrationType = 'individual',
    this.minTeamSize = 1,
    this.maxTeamSize = 1,
    this.paymentMethod = 'FREE',
    this.registrationFee = 0.0,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.club,
    this.subtitle,
    this.imageLocation,
    this.isRegistered = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      venue: json['venue'],
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      totalSeats: json['totalSeats'],
      entryFee: json['entryFee'] != null ? (json['entryFee'] as num).toDouble() : null,
      allowedPrograms: List<String>.from(json['allowedPrograms'] ?? []),
      allowedYears: List<String>.from(json['allowedYears'] ?? []),
      allowedBranches: List<String>.from(json['allowedBranches'] ?? []),
      imageUrl: json['imageUrl'] ?? json['imageLocation'],
      registeredCount: json['registeredCount'] ?? 0,
      views: json['views'] ?? 0,
      waitingListIds: List<String>.from(json['waitingListIds'] ?? []),
      requiredFields: List<String>.from(json['requiredFields'] ?? []),
      createdById: json['createdById'],
      clubId: json['clubId'],
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.tryParse(json['registrationDeadline'])
          : null,
      reviewStatus: json['reviewStatus'],
      winners: json['winners'],
      showWinner: json['showWinner'] ?? false,
      provideCertificate: json['provideCertificate'] ?? false,
      registrationType: json['registrationType'] ?? 'individual',
      minTeamSize: json['minTeamSize'] ?? 1,
      maxTeamSize: json['maxTeamSize'] ?? 1,
      paymentMethod: json['paymentMethod'] ?? 'FREE',
      registrationFee: json['registrationFee'] != null
          ? (json['registrationFee'] as num).toDouble()
          : 0.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      createdBy: json['createdBy'] != null ? EventCreatorModel.fromJson(json['createdBy']) : null,
      club: json['club'] != null ? EventClubInfoModel.fromJson(json['club']) : null,
      subtitle: json['subtitle'] ?? json['venue'] ?? '',
      imageLocation: json['imageLocation'] ?? json['imageUrl'] ?? '',
      isRegistered: json['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'venue': venue,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalSeats': totalSeats,
      'entryFee': entryFee,
      'allowedPrograms': allowedPrograms,
      'allowedYears': allowedYears,
      'allowedBranches': allowedBranches,
      'imageUrl': imageUrl,
      'registeredCount': registeredCount,
      'views': views,
      'waitingListIds': waitingListIds,
      'requiredFields': requiredFields,
      'createdById': createdById,
      'clubId': clubId,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'reviewStatus': reviewStatus,
      'winners': winners,
      'showWinner': showWinner,
      'provideCertificate': provideCertificate,
      'registrationType': registrationType,
      'minTeamSize': minTeamSize,
      'maxTeamSize': maxTeamSize,
      'paymentMethod': paymentMethod,
      'registrationFee': registrationFee,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy?.toJson(),
      'club': club?.toJson(),
      'subtitle': subtitle,
      'imageLocation': imageLocation,
      'isRegistered': isRegistered,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    String? venue,
    DateTime? startTime,
    DateTime? endTime,
    int? totalSeats,
    double? entryFee,
    List<String>? allowedPrograms,
    List<String>? allowedYears,
    List<String>? allowedBranches,
    String? imageUrl,
    int? registeredCount,
    int? views,
    List<String>? waitingListIds,
    List<String>? requiredFields,
    String? createdById,
    String? clubId,
    DateTime? registrationDeadline,
    String? reviewStatus,
    List<dynamic>? winners,
    bool? showWinner,
    bool? provideCertificate,
    String? registrationType,
    int? minTeamSize,
    int? maxTeamSize,
    String? paymentMethod,
    double? registrationFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    EventCreatorModel? createdBy,
    EventClubInfoModel? club,
    String? subtitle,
    String? imageLocation,
    bool? isRegistered,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalSeats: totalSeats ?? this.totalSeats,
      entryFee: entryFee ?? this.entryFee,
      allowedPrograms: allowedPrograms ?? this.allowedPrograms,
      allowedYears: allowedYears ?? this.allowedYears,
      allowedBranches: allowedBranches ?? this.allowedBranches,
      imageUrl: imageUrl ?? this.imageUrl,
      registeredCount: registeredCount ?? this.registeredCount,
      views: views ?? this.views,
      waitingListIds: waitingListIds ?? this.waitingListIds,
      requiredFields: requiredFields ?? this.requiredFields,
      createdById: createdById ?? this.createdById,
      clubId: clubId ?? this.clubId,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      winners: winners ?? this.winners,
      showWinner: showWinner ?? this.showWinner,
      provideCertificate: provideCertificate ?? this.provideCertificate,
      registrationType: registrationType ?? this.registrationType,
      minTeamSize: minTeamSize ?? this.minTeamSize,
      maxTeamSize: maxTeamSize ?? this.maxTeamSize,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      registrationFee: registrationFee ?? this.registrationFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      club: club ?? this.club,
      subtitle: subtitle ?? this.subtitle,
      imageLocation: imageLocation ?? this.imageLocation,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        description,
        venue,
        startTime,
        endTime,
        totalSeats,
        entryFee,
        allowedPrograms,
        allowedYears,
        allowedBranches,
        imageUrl,
        registeredCount,
        views,
        waitingListIds,
        requiredFields,
        createdById,
        clubId,
        registrationDeadline,
        reviewStatus,
        winners,
        showWinner,
        provideCertificate,
        registrationType,
        minTeamSize,
        maxTeamSize,
        paymentMethod,
        registrationFee,
        createdAt,
        updatedAt,
        createdBy,
        club,
        subtitle,
        imageLocation,
        isRegistered,
      ];
}
