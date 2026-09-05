import 'package:equatable/equatable.dart';
import 'event_model.dart';

class ParticipationModel extends Equatable {
  final String id;
  final String? studentId;
  final String? eventId;
  final String? externalEmail;
  final String? externalName;
  final String status; // "REGISTERED" | "WAITLISTED" | "ATTENDED"
  final String qrCode;
  final DateTime? attendedAt;
  final String? markedByMemberId;
  final Map<String, dynamic>? student;
  final EventModel? event;
  final double amountPaid;
  final String? paymentStatus;
  final String? paymentId;
  final String? orderId;
  final DateTime? createdAt;

  const ParticipationModel({
    required this.id,
    this.studentId,
    this.eventId,
    this.externalEmail,
    this.externalName,
    required this.status,
    required this.qrCode,
    this.attendedAt,
    this.markedByMemberId,
    this.student,
    this.event,
    this.amountPaid = 0.0,
    this.paymentStatus,
    this.paymentId,
    this.orderId,
    this.createdAt,
  });

  bool get isAttended => status == 'ATTENDED' || attendedAt != null;

  String get participantName =>
      student?['name']?.toString() ??
      externalName ??
      'Participant';

  String? get participantRollNo => student?['rollNo']?.toString();

  String get participantEmail =>
      student?['email']?.toString() ?? externalEmail ?? '';

  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    EventModel? parsedEvent;
    String? rawEventId;

    if (json['eventId'] is Map<String, dynamic>) {
      parsedEvent = EventModel.fromJson(json['eventId'], isRegistered: true);
      rawEventId = parsedEvent.id;
    } else if (json['event'] is Map<String, dynamic>) {
      parsedEvent = EventModel.fromJson(json['event'], isRegistered: true);
      rawEventId = parsedEvent.id;
    } else if (json['eventId'] != null) {
      rawEventId = json['eventId'].toString();
    }

    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is DateTime) return date;
      try {
        return DateTime.parse(date.toString());
      } catch (_) {
        return null;
      }
    }

    return ParticipationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? json['userId']?.toString(),
      eventId: rawEventId,
      externalEmail: json['externalEmail']?.toString(),
      externalName: json['externalName']?.toString(),
      status: json['status']?.toString() ?? 'REGISTERED',
      qrCode: json['qrCode']?.toString() ?? '',
      attendedAt: parseDate(json['attendedAt']),
      markedByMemberId: json['markedByMemberId']?.toString(),
      student: json['student'] is Map<String, dynamic> ? json['student'] : null,
      event: parsedEvent,
      amountPaid: (json['amountPaid'] is num) ? (json['amountPaid'] as num).toDouble() : 0.0,
      paymentStatus: json['paymentStatus']?.toString(),
      paymentId: json['paymentId']?.toString(),
      orderId: json['orderId']?.toString(),
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'eventId': eventId,
      'externalEmail': externalEmail,
      'externalName': externalName,
      'status': status,
      'qrCode': qrCode,
      'attendedAt': attendedAt?.toIso8601String(),
      'markedByMemberId': markedByMemberId,
      if (student != null) 'student': student,
      if (event != null) 'event': event?.toJson(),
      'amountPaid': amountPaid,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'orderId': orderId,
    };
  }

  @override
  List<Object?> get props => [id, studentId, eventId, externalEmail, status, qrCode, attendedAt];
}
