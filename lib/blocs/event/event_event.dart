import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllEvents extends EventEvent {}

class RegisterForEvent extends EventEvent {
  final String eventId;
  final String? externalEmail;
  final String? externalName;
  final String? transactionId;
  final String? payerName;
  final String? paymentRemarks;
  final Map<String, dynamic>? formResponses;

  const RegisterForEvent({
    required this.eventId,
    this.externalEmail,
    this.externalName,
    this.transactionId,
    this.payerName,
    this.paymentRemarks,
    this.formResponses,
  });

  @override
  List<Object?> get props => [
        eventId,
        externalEmail,
        externalName,
        transactionId,
        payerName,
        paymentRemarks,
        formResponses,
      ];
}

class DeregisterFromEvent extends EventEvent {
  final String eventId;
  final String studentId;

  const DeregisterFromEvent({
    required this.eventId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [eventId, studentId];
}

