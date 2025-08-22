class User {
  final String uid;
  final String email;
  final String name;
  final int? rollno;
  final String? branch;
  final String? hostelName;
  final String? roomNo;
  final String? skills;
  final String? role;

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.rollno,
    this.branch,
    this.hostelName,
    this.roomNo,
    this.skills,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      rollno: json['rollno'],
      branch: json['branch'],
      hostelName: json['hostelName'],
      roomNo: json['roomNo'],
      skills: json['skills'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'rollno': rollno,
      'branch': branch,
      'hostelName': hostelName,
      'roomNo': roomNo,
      'skills': skills,
      'role': role,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? name,
    int? rollno,
    String? branch,
    String? hostelName,
    String? roomNo,
    String? skills,
    String? role,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      rollno: rollno ?? this.rollno,
      branch: branch ?? this.branch,
      hostelName: hostelName ?? this.hostelName,
      roomNo: roomNo ?? this.roomNo,
      skills: skills ?? this.skills,
      role: role ?? this.role,
    );
  }
}

class Event {
  final String id;
  final String name;
  final DateTime eventDate;
  final String description;
  final List<String> participants;

  Event({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.description,
    required this.participants,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      eventDate: DateTime.parse(json['event_date']),
      description: json['description'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'description': description,
      'participants': participants,
    };
  }
}

class AuthResponse {
  final String message;
  final String? uid;
  final String? idToken;
  final String? refreshToken;

  AuthResponse({
    required this.message,
    this.uid,
    this.idToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      uid: json['uid'],
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
    );
  }
}