import 'package:equatable/equatable.dart';

abstract class HeadEvent extends Equatable {
  const HeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardStats extends HeadEvent {
  final String? clubId;

  const FetchDashboardStats({this.clubId});

  @override
  List<Object?> get props => [clubId];
}

class FetchClubEvents extends HeadEvent {
  final String clubId;

  const FetchClubEvents(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

class CreateClubEvent extends HeadEvent {
  final Map<String, dynamic> eventData;

  const CreateClubEvent(this.eventData);

  @override
  List<Object?> get props => [eventData];
}

class UpdateClubEvent extends HeadEvent {
  final String eventId;
  final Map<String, dynamic> eventData;

  const UpdateClubEvent(this.eventId, this.eventData);

  @override
  List<Object?> get props => [eventId, eventData];
}

class DeleteClubEvent extends HeadEvent {
  final String eventId;
  final String? clubId;

  const DeleteClubEvent(this.eventId, {this.clubId});

  @override
  List<Object?> get props => [eventId, clubId];
}

class FetchClubMembers extends HeadEvent {
  final String clubId;

  const FetchClubMembers(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

class AddClubMemberRequested extends HeadEvent {
  final String clubId;
  final String email;
  final String role;

  const AddClubMemberRequested(this.clubId, this.email, {this.role = 'MEMBER'});

  @override
  List<Object?> get props => [clubId, email, role];
}

class UpdateMemberPermissionsRequested extends HeadEvent {
  final String membershipId;
  final String? role;
  final bool? canTakeAttendance;
  final bool? canEditEvents;
  final String? clubId;

  const UpdateMemberPermissionsRequested(
    this.membershipId, {
    this.role,
    this.canTakeAttendance,
    this.canEditEvents,
    this.clubId,
  });

  @override
  List<Object?> get props => [membershipId, role, canTakeAttendance, canEditEvents, clubId];
}

class RemoveClubMemberRequested extends HeadEvent {
  final String membershipId;
  final String? clubId;

  const RemoveClubMemberRequested(this.membershipId, {this.clubId});

  @override
  List<Object?> get props => [membershipId, clubId];
}

class CheckInQrRequested extends HeadEvent {
  final String eventId;
  final String qrCode;

  const CheckInQrRequested(this.eventId, this.qrCode);

  @override
  List<Object?> get props => [eventId, qrCode];
}

class CheckInManualRequested extends HeadEvent {
  final String eventId;
  final String participationId;

  const CheckInManualRequested(this.eventId, this.participationId);

  @override
  List<Object?> get props => [eventId, participationId];
}

class SendAnnouncementRequested extends HeadEvent {
  final String title;
  final String message;
  final String targetType;
  final String? eventId;

  const SendAnnouncementRequested({
    required this.title,
    required this.message,
    this.targetType = 'ALL_STUDENTS',
    this.eventId,
  });

  @override
  List<Object?> get props => [title, message, targetType, eventId];
}

