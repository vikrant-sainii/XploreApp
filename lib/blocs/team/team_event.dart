import 'package:equatable/equatable.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

class RegisterTeamRequested extends TeamEvent {
  final String eventId;
  final String teamName;
  final List<String> memberIds;
  final Map<String, dynamic>? formResponses;
  final String? transactionId;
  final String? payerName;
  final String? paymentRemarks;

  const RegisterTeamRequested({
    required this.eventId,
    required this.teamName,
    required this.memberIds,
    this.formResponses,
    this.transactionId,
    this.payerName,
    this.paymentRemarks,
  });

  @override
  List<Object?> get props => [
        eventId,
        teamName,
        memberIds,
        formResponses,
        transactionId,
        payerName,
        paymentRemarks,
      ];
}

class AcceptTeamInvitation extends TeamEvent {
  final String notificationId;

  const AcceptTeamInvitation(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeclineTeamInvitation extends TeamEvent {
  final String notificationId;

  const DeclineTeamInvitation(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class InviteTeamMember extends TeamEvent {
  final String teamId;
  final String studentId;

  const InviteTeamMember({required this.teamId, required this.studentId});

  @override
  List<Object?> get props => [teamId, studentId];
}

class FetchTeamDetails extends TeamEvent {
  final String teamId;

  const FetchTeamDetails(this.teamId);

  @override
  List<Object?> get props => [teamId];
}
