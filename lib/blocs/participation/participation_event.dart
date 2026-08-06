import 'package:equatable/equatable.dart';

abstract class ParticipationEvent extends Equatable {
  const ParticipationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyQRAttendance extends ParticipationEvent {
  final String qrCode;

  const VerifyQRAttendance(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

class FetchEventRegistrations extends ParticipationEvent {
  final String eventId;

  const FetchEventRegistrations(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
