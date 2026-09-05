import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime? createdAt;
  final List<String> readBy;
  final String? senderStudentId;
  final String? senderAdminId;
  final Map<String, dynamic>? sender;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.createdAt,
    this.readBy = const [],
    this.senderStudentId,
    this.senderAdminId,
    this.sender,
  });

  String get senderName =>
      sender?['clubName']?.toString() ??
      sender?['name']?.toString() ??
      'Admin / Club Head';

  String get senderEmail => sender?['email']?.toString() ?? '';

  bool isReadBy(String userId) => readBy.contains(userId);

  String get formattedTime {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is DateTime) return date;
      try {
        return DateTime.parse(date.toString());
      } catch (_) {
        return null;
      }
    }

    List<String> parsedReadBy = [];
    if (json['readBy'] is List) {
      parsedReadBy = (json['readBy'] as List).map((e) => e.toString()).toList();
    }

    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      readBy: parsedReadBy,
      senderStudentId: json['senderStudentId']?.toString(),
      senderAdminId: json['senderAdminId']?.toString(),
      sender: json['sender'] is Map<String, dynamic> ? json['sender'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'readBy': readBy,
      'senderStudentId': senderStudentId,
      'senderAdminId': senderAdminId,
      if (sender != null) 'sender': sender,
    };
  }

  @override
  List<Object?> get props => [id, title, message, createdAt, readBy];
}
