import 'package:equatable/equatable.dart';
import 'event_model.dart';
import 'user_model.dart';

class ParticipationModel extends Equatable {
  final String id;
  final String eventId;
  final String? studentId;
  final String status;
  final String? qrCode;
  final double amountPaid;
  final String paymentStatus;
  final Map<String, dynamic>? formResponses;
  final EventModel? event;
  final UserModel? student;
  final String? transactionId;
  final String? paymentReviewMessage;
  final String? externalEmail;
  final String? externalName;

  const ParticipationModel({
    required this.id,
    required this.eventId,
    this.studentId,
    required this.status,
    this.qrCode,
    this.amountPaid = 0.0,
    required this.paymentStatus,
    this.formResponses,
    this.event,
    this.student,
    this.transactionId,
    this.paymentReviewMessage,
    this.externalEmail,
    this.externalName,
  });

  bool get isAttended => status.toUpperCase() == 'ATTENDED';



  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    // 1. Handle eventId (can be String or populated Map from backend)
    String parsedEventId = '';
    EventModel? parsedEvent;

    final rawEventId = json['eventId'];
    final rawEvent = json['event'];

    if (rawEventId is String) {
      parsedEventId = rawEventId;
    } else if (rawEventId is Map<String, dynamic>) {
      parsedEventId = (rawEventId['id'] ?? rawEventId['_id'] ?? '').toString();
      parsedEvent = EventModel.fromJson(rawEventId);
    }

    if (parsedEvent == null && rawEvent is Map<String, dynamic>) {
      parsedEvent = EventModel.fromJson(rawEvent);
      if (parsedEventId.isEmpty) {
        parsedEventId = parsedEvent.id;
      }
    }

    // 2. Handle studentId (can be String or populated Map from backend)
    String? parsedStudentId;
    UserModel? parsedStudent;

    final rawStudentId = json['studentId'];
    final rawStudent = json['student'];

    if (rawStudentId is String) {
      parsedStudentId = rawStudentId;
    } else if (rawStudentId is Map<String, dynamic>) {
      parsedStudentId = (rawStudentId['id'] ?? rawStudentId['_id'])?.toString();
      parsedStudent = UserModel.fromJson(rawStudentId);
    }

    if (parsedStudent == null && rawStudent is Map<String, dynamic>) {
      parsedStudent = UserModel.fromJson(rawStudent);
      if (parsedStudentId == null || parsedStudentId.isEmpty) {
        parsedStudentId = parsedStudent.id;
      }
    }

    return ParticipationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      eventId: parsedEventId,
      studentId: parsedStudentId,
      status: (json['status'] ?? 'REGISTERED').toString(),
      qrCode: json['qrCode']?.toString(),
      amountPaid: json['amountPaid'] != null ? (json['amountPaid'] as num).toDouble() : 0.0,
      paymentStatus: (json['paymentStatus'] ?? 'PENDING').toString(),
      formResponses: json['formResponses'] is Map<String, dynamic> ? json['formResponses'] : null,
      event: parsedEvent,
      student: parsedStudent,
      transactionId: json['transactionId']?.toString(),
      paymentReviewMessage: json['paymentReviewMessage']?.toString(),
      externalEmail: json['externalEmail']?.toString(),
      externalName: json['externalName']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'studentId': studentId,
      'status': status,
      'qrCode': qrCode,
      'amountPaid': amountPaid,
      'paymentStatus': paymentStatus,
      'formResponses': formResponses,
      'event': event?.toJson(),
      'student': student?.toJson(),
      'transactionId': transactionId,
      'paymentReviewMessage': paymentReviewMessage,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        studentId,
        status,
        qrCode,
        amountPaid,
        paymentStatus,
        formResponses,
        event,
        student,
        transactionId,
        paymentReviewMessage,
      ];
}
