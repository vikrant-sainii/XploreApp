import 'package:equatable/equatable.dart';
import '../../models/participation_model.dart';

abstract class ParticipationState extends Equatable {
  const ParticipationState();

  @override
  List<Object?> get props => [];
}

class ParticipationInitial extends ParticipationState {}

class ParticipationLoading extends ParticipationState {}

class QRAttendanceSuccess extends ParticipationState {
  final String participantName;
  final String? rollNo;
  final String? externalEmail;
  final DateTime? attendedAt;

  const QRAttendanceSuccess({
    required this.participantName,
    this.rollNo,
    this.externalEmail,
    this.attendedAt,
  });

  @override
  List<Object?> get props => [participantName, rollNo, externalEmail, attendedAt];
}

class EventRegistrationsLoaded extends ParticipationState {
  final List<ParticipationModel> registrations;

  const EventRegistrationsLoaded(this.registrations);

  @override
  List<Object?> get props => [registrations];
}

class ParticipationError extends ParticipationState {
  final String message;

  const ParticipationError(this.message);

  @override
  List<Object?> get props => [message];
}
