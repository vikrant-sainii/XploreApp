import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? venue;
  final DateTime? startTime;
  final DateTime? endTime;
  final int totalSeats;
  final int registeredCount;
  final double entryFee;
  final String? imageUrl;
  final List<String> requiredFields;
  final List<dynamic> customFields;
  final List<String> allowedPrograms;
  final List<String> allowedYears;
  final DateTime? registrationDeadline;
  final String reviewStatus; // "PENDING" | "PUBLISHED" | "REJECTED"
  final String? reviewComment;
  final String? rules;
  final bool onlyCollegeStudents;
  final String? clubId;
  final Map<String, dynamic>? club;
  final Map<String, dynamic>? createdBy;
  final Map<String, dynamic>? reviewedBy;
  final List<dynamic> sponsors;
  final List<dynamic> media;
  final List<dynamic> waitingList;
  final String status; // "UPCOMING" | "LIVE" | "COMPLETED"
  final int attendedCount;
  final bool isRegistered;
  final bool isOpenEntryFlag;
  final String registrationType; // "none" | "individual" | "team" | "both"
  final int minTeamSize;
  final int maxTeamSize;
  final bool allowExternalParticipants;
  final List<String> allowedBranches;
  final String? postRegistrationMessage;
  final String paymentMethod; // "free" | "manual" | "college_portal"
  final String? paymentDetails;
  final String? upiId;
  final String? accountHolderName;
  final String? paymentInstructions;
  final String? collegePaymentUrl;
  final bool showWinner;
  final dynamic winners;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    this.venue,
    this.startTime,
    this.endTime,
    this.totalSeats = 0,
    this.registeredCount = 0,
    this.entryFee = 0.0,
    this.imageUrl,
    this.requiredFields = const [],
    this.customFields = const [],
    this.allowedPrograms = const ['BTECH', 'MTECH', 'OTHER'],
    this.allowedYears = const [],
    this.allowedBranches = const [],
    this.registrationDeadline,
    this.reviewStatus = 'PUBLISHED',
    this.reviewComment,
    this.rules,
    this.onlyCollegeStudents = true,
    this.clubId,
    this.club,
    this.createdBy,
    this.reviewedBy,
    this.sponsors = const [],
    this.media = const [],
    this.waitingList = const [],
    this.status = 'UPCOMING',
    this.attendedCount = 0,
    this.isRegistered = false,
    bool isOpenEntry = false,
    bool? isOpenEntryFlag,
    this.registrationType = 'individual',
    this.minTeamSize = 1,
    this.maxTeamSize = 4,
    this.allowExternalParticipants = true,
    this.postRegistrationMessage,
    this.paymentMethod = 'free',
    this.paymentDetails,
    this.upiId,
    this.accountHolderName,
    this.paymentInstructions,
    this.collegePaymentUrl,
    this.showWinner = false,
    this.winners,
  }) : isOpenEntryFlag = isOpenEntryFlag ?? isOpenEntry;



  bool get isOpenEntry => registrationType.toLowerCase() == 'none' || isOpenEntryFlag;
  bool get isTeamRegistration => registrationType.toLowerCase() == 'team';
  bool get isIndividualRegistration => registrationType.toLowerCase() == 'individual' || (!isOpenEntry && !isTeamRegistration);

  String get clubName => club?['clubName']?.toString() ?? club?['name']?.toString() ?? 'College Club';

  String? _getSocialUrl(String fieldKey, String platformName) {
    if (club == null) return null;
    final direct = club![fieldKey]?.toString() ?? club![platformName]?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    
    final links = club!['socialLinks'];
    if (links is Map) {
      final val = links[platformName]?.toString() ?? links[fieldKey]?.toString();
      if (val != null && val.isNotEmpty) return val;
    } else if (links is List) {
      for (var item in links) {
        if (item is Map) {
          final platform = item['platform']?.toString().toLowerCase();
          if (platform == platformName.toLowerCase() || platform == fieldKey.toLowerCase()) {
            final url = item['url']?.toString();
            if (url != null && url.isNotEmpty) return url;
          }
        }
      }
    }
    return null;
  }

  String? get instagramUrl => _getSocialUrl('instagramUrl', 'instagram');
  String? get linkedinUrl => _getSocialUrl('linkedInUrl', 'linkedin');
  String? get twitterUrl => _getSocialUrl('twitterUrl', 'twitter');
  String? get portfolioUrl => _getSocialUrl('portfolioUrl', 'website');
  String? get whatsappNumber => _getSocialUrl('whatsappNumber', 'whatsapp');

  String get subtitle {
    if (venue != null && venue!.isNotEmpty) {
      return 'Venue : $venue';
    }
    if (entryFee == 0) {
      return 'Free Event';
    }
    return '₹$entryFee Entry';
  }

  String get formattedTime {
    if (startTime == null) return '5:30 PM';
    final hour = startTime!.hour > 12 ? startTime!.hour - 12 : (startTime!.hour == 0 ? 12 : startTime!.hour);
    final minute = startTime!.minute.toString().padLeft(2, '0');
    final period = startTime!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get formattedDate {
    if (startTime == null) return 'Upcoming';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${startTime!.day} ${months[startTime!.month - 1]} ${startTime!.year}';
  }

  String get formattedDateWithTime {
    if (startTime == null) return 'Sunday, 6 September 2026 at 20:00';
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final weekday = weekdays[startTime!.weekday - 1];
    final day = startTime!.day;
    final month = months[startTime!.month - 1];
    final year = startTime!.year;
    final hour = startTime!.hour.toString().padLeft(2, '0');
    final minute = startTime!.minute.toString().padLeft(2, '0');
    return '$weekday, $day $month $year at $hour:$minute';
  }

  String get formattedEndDateWithTime {
    if (endTime == null) return '';
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final weekday = weekdays[endTime!.weekday - 1];
    final day = endTime!.day;
    final month = months[endTime!.month - 1];
    final year = endTime!.year;
    final hour = endTime!.hour.toString().padLeft(2, '0');
    final minute = endTime!.minute.toString().padLeft(2, '0');
    return '$weekday, $day $month $year at $hour:$minute';
  }

  String get imageLocation {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    return 'assets/gdgc.png';
  }

  bool get isPaid => entryFee > 0;

  bool get isFull => totalSeats > 0 && registeredCount >= totalSeats;

  bool get providesCertificate {
    if (title.toLowerCase().contains('fresher') || isOpenEntry) return false;
    return true;
  }

  factory EventModel.fromJson(Map<String, dynamic> json, {bool isRegistered = false}) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is DateTime) return date;
      try {
        return DateTime.parse(date.toString());
      } catch (_) {
        return null;
      }
    }

    double parseFee(dynamic fee) {
      if (fee == null) return 0.0;
      if (fee is num) return fee.toDouble();
      return double.tryParse(fee.toString()) ?? 0.0;
    }

    int parseInt(dynamic val, {int defaultValue = 0}) {
      if (val == null) return defaultValue;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? defaultValue;
    }

    final String rawRegType = json['registrationType']?.toString().toLowerCase() ?? '';
    final bool openEntry = rawRegType == 'none' ||
        json['isOpenEntry'] == true ||
        json['isOpen'] == true ||
        json['isWalkIn'] == true ||
        json['registrationRequired'] == false ||
        json['type']?.toString().toUpperCase() == 'OPEN' ||
        json['entryType']?.toString().toUpperCase() == 'OPEN' ||
        (json['title']?.toString().toLowerCase().contains('fresher') ?? false);

    final String resolvedRegType = rawRegType.isNotEmpty
        ? rawRegType
        : (openEntry ? 'none' : 'individual');

    return EventModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['eventName']?.toString() ?? 'Event',
      description: json['description']?.toString(),
      venue: json['venue']?.toString(),
      startTime: parseDate(json['startTime'] ?? json['eventDate']),
      endTime: parseDate(json['endTime']),
      totalSeats: parseInt(json['totalSeats']),
      registeredCount: parseInt(json['registeredCount'] ?? json['totalRegistrations']),
      entryFee: parseFee(json['entryFee'] ?? json['totalAmountReceived']),
      imageUrl: json['imageUrl']?.toString() ?? json['imageLocation']?.toString(),
      requiredFields: (json['requiredFields'] is List)
          ? (json['requiredFields'] as List).map((e) => e.toString()).toList()
          : const [],
      customFields: (json['customFields'] is List) ? json['customFields'] : const [],
      allowedPrograms: (json['allowedPrograms'] is List)
          ? (json['allowedPrograms'] as List).map((e) => e.toString()).toList()
          : const ['BTECH', 'MTECH', 'OTHER'],
      allowedYears: (json['allowedYears'] is List)
          ? (json['allowedYears'] as List).map((e) => e.toString()).toList()
          : const [],
      allowedBranches: (json['allowedBranches'] is List)
          ? (json['allowedBranches'] as List).map((e) => e.toString()).toList()
          : const [],
      registrationDeadline: parseDate(json['registrationDeadline']),
      reviewStatus: json['reviewStatus']?.toString() ?? 'PUBLISHED',
      reviewComment: json['reviewComment']?.toString() ?? json['rejectionComment']?.toString(),
      rules: json['rules']?.toString() ?? json['rulesAndGuidelines']?.toString(),
      onlyCollegeStudents: json['onlyCollegeStudents'] == true || json['onlyNitjStudents'] == true || json['collegeStudentsOnly'] == true || true,
      clubId: json['clubId']?.toString() ?? (json['club'] is String ? json['club'].toString() : (json['club'] is Map ? json['club']['id']?.toString() ?? json['club']['_id']?.toString() : null)),
      club: json['club'] is Map ? Map<String, dynamic>.from(json['club'] as Map) : null,
      createdBy: json['createdBy'] is Map<String, dynamic> ? json['createdBy'] : null,
      reviewedBy: json['reviewedBy'] is Map<String, dynamic> ? json['reviewedBy'] : null,
      sponsors: json['sponsors'] is List ? json['sponsors'] : const [],
      media: json['media'] is List ? json['media'] : const [],
      waitingList: json['waitingList'] is List ? json['waitingList'] : const [],
      status: json['status']?.toString() ?? 'UPCOMING',
      attendedCount: parseInt(json['attendedCount']),
      isRegistered: isRegistered || json['isRegistered'] == true,
      isOpenEntryFlag: openEntry,
      registrationType: resolvedRegType,
      minTeamSize: parseInt(json['minTeamSize'], defaultValue: 1),
      maxTeamSize: parseInt(json['maxTeamSize'], defaultValue: 4),
      allowExternalParticipants: json['allowExternalParticipants'] ?? json['allowExternal'] ?? true,
      postRegistrationMessage: json['postRegistrationMessage']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'free',
      paymentDetails: json['paymentDetails']?.toString(),
      upiId: json['upiId']?.toString() ?? json['upi']?.toString(),
      accountHolderName: json['accountHolderName']?.toString(),
      paymentInstructions: json['paymentInstructions']?.toString() ?? json['instructions']?.toString(),
      collegePaymentUrl: json['collegePaymentUrl']?.toString() ?? json['collegePortalUrl']?.toString(),
      showWinner: json['showWinner'] == true || json['displayResults'] == true,
      winners: json['winners'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rules': rules,
      'venue': venue,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalSeats': totalSeats,
      'registeredCount': registeredCount,
      'entryFee': entryFee,
      'imageUrl': imageUrl,
      'requiredFields': requiredFields,
      'customFields': customFields,
      'allowedPrograms': allowedPrograms,
      'allowedYears': allowedYears,
      'allowedBranches': allowedBranches,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'reviewStatus': reviewStatus,
      'reviewComment': reviewComment,
      'onlyCollegeStudents': onlyCollegeStudents,
      'clubId': clubId,
      'status': status,
      'attendedCount': attendedCount,
      'isRegistered': isRegistered,
      'isOpenEntry': isOpenEntry,
      'registrationType': registrationType,
      'minTeamSize': minTeamSize,
      'maxTeamSize': maxTeamSize,
      'allowExternalParticipants': allowExternalParticipants,
      'postRegistrationMessage': postRegistrationMessage,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'upiId': upiId,
      'accountHolderName': accountHolderName,
      'paymentInstructions': paymentInstructions,
      'collegePaymentUrl': collegePaymentUrl,
      'showWinner': showWinner,
      'winners': winners,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final String pm = paymentMethod.toUpperCase();
    final String resolvedPaymentMethod = (pm == 'FREE' || pm == 'MANUAL' || pm == 'COLLEGE_PORTAL')
        ? pm
        : (entryFee > 0 ? 'MANUAL' : 'FREE');

    final map = <String, dynamic>{
      'title': title,
      'description': description ?? '',
      'venue': (venue != null && venue!.isNotEmpty) ? venue : 'CSH',
      'startTime': (startTime ?? DateTime.now().add(const Duration(days: 1))).toIso8601String(),
      'endTime': (endTime ?? DateTime.now().add(const Duration(days: 1, hours: 2))).toIso8601String(),
      'totalSeats': totalSeats,
      'entryFee': entryFee,
      'registrationFee': entryFee,
      'imageUrl': imageUrl ?? '',
      'requiredFields': requiredFields,
      'customFields': customFields,
      'allowedPrograms': allowedPrograms.isNotEmpty ? allowedPrograms : ['BTECH', 'MTECH', 'OTHER'],
      'allowedYears': allowedYears,
      'allowedBranches': allowedBranches,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'reviewStatus': 'PENDING',
      'registrationType': registrationType,
      'minTeamSize': minTeamSize,
      'maxTeamSize': maxTeamSize,
      'allowExternal': allowExternalParticipants,
      'allowExternalParticipants': allowExternalParticipants,
      'postRegistrationMessage': postRegistrationMessage,
      'paymentMethod': resolvedPaymentMethod,
      'upiId': upiId,
      'accountHolderName': accountHolderName,
      'paymentInstructions': paymentInstructions,
      'collegePaymentUrl': collegePaymentUrl,
      'showWinner': showWinner,
      'provideCertificate': providesCertificate,
      'feedbackEnabled': true,
      'rules': rules,
      'organizerType': 'CLUB',
      'sponsors': sponsors,
      'media': media,
    };

    if (createdBy != null) {
      if (createdBy is String) {
        map['createdBy'] = createdBy;
      } else if (createdBy is Map && createdBy!['id'] != null) {
        map['createdBy'] = createdBy!['id'];
      }
    }

    if (id.isNotEmpty && !id.startsWith('draft-')) {
      map['id'] = id;
    }

    if (clubId != null && clubId!.isNotEmpty) {
      map['clubId'] = clubId;
    }

    return map;
  }




  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? venue,
    DateTime? startTime,
    DateTime? endTime,
    int? totalSeats,
    int? registeredCount,
    double? entryFee,
    String? imageUrl,
    List<String>? requiredFields,
    List<dynamic>? customFields,
    List<String>? allowedPrograms,
    List<String>? allowedYears,
    DateTime? registrationDeadline,
    String? reviewStatus,
    String? clubId,
    Map<String, dynamic>? club,
    Map<String, dynamic>? createdBy,
    Map<String, dynamic>? reviewedBy,
    List<dynamic>? sponsors,
    List<dynamic>? media,
    List<dynamic>? waitingList,
    String? status,
    int? attendedCount,
    bool? isRegistered,
    bool? isOpenEntryFlag,
    String? registrationType,
    int? minTeamSize,
    int? maxTeamSize,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalSeats: totalSeats ?? this.totalSeats,
      registeredCount: registeredCount ?? this.registeredCount,
      entryFee: entryFee ?? this.entryFee,
      imageUrl: imageUrl ?? this.imageUrl,
      requiredFields: requiredFields ?? this.requiredFields,
      customFields: customFields ?? this.customFields,
      allowedPrograms: allowedPrograms ?? this.allowedPrograms,
      allowedYears: allowedYears ?? this.allowedYears,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      clubId: clubId ?? this.clubId,
      club: club ?? this.club,
      createdBy: createdBy ?? this.createdBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      sponsors: sponsors ?? this.sponsors,
      media: media ?? this.media,
      waitingList: waitingList ?? this.waitingList,
      status: status ?? this.status,
      attendedCount: attendedCount ?? this.attendedCount,
      isRegistered: isRegistered ?? this.isRegistered,
      isOpenEntryFlag: isOpenEntryFlag ?? this.isOpenEntryFlag,
      registrationType: registrationType ?? this.registrationType,
      minTeamSize: minTeamSize ?? this.minTeamSize,
      maxTeamSize: maxTeamSize ?? this.maxTeamSize,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        venue,
        startTime,
        endTime,
        totalSeats,
        registeredCount,
        entryFee,
        imageUrl,
        reviewStatus,
        clubId,
        status,
        isRegistered,
        isOpenEntryFlag,
        registrationType,
        minTeamSize,
        maxTeamSize,
      ];
}
