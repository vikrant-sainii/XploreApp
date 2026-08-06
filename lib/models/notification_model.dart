import 'package:equatable/equatable.dart';

class NotificationSenderModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? clubName;

  const NotificationSenderModel({
    required this.id,
    required this.name,
    required this.email,
    this.clubName,
  });

  factory NotificationSenderModel.fromJson(Map<String, dynamic> json) {
    return NotificationSenderModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      clubName: json['clubName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'clubName': clubName,
    };
  }

  @override
  List<Object?> get props => [id, name, email, clubName];
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String? recipientStudentId;
  final String? eventId;
  final String? teamId;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final NotificationSenderModel? sender;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.recipientStudentId,
    this.eventId,
    this.teamId,
    required this.type,
    this.isRead = false,
    this.createdAt,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // sender format helper might have already formatted it
    var senderJson = json['sender'];
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      recipientStudentId: json['recipientStudentId'],
      eventId: json['eventId'],
      teamId: json['teamId'],
      type: json['type'] ?? 'GENERAL',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      sender: senderJson != null ? NotificationSenderModel.fromJson(senderJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'recipientStudentId': recipientStudentId,
      'eventId': eventId,
      'teamId': teamId,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'sender': sender?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        recipientStudentId,
        eventId,
        teamId,
        type,
        isRead,
        createdAt,
        sender,
      ];
}
