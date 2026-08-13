import 'package:equatable/equatable.dart';

abstract class HeadEvent extends Equatable {
  const HeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardStats extends HeadEvent {}

class CreateEventRequested extends HeadEvent {
  final Map<String, dynamic> eventData;

  const CreateEventRequested(this.eventData);

  @override
  List<Object?> get props => [eventData];
}

class UpdateEventRequested extends HeadEvent {
  final String eventId;
  final Map<String, dynamic> eventData;

  const UpdateEventRequested(this.eventId, this.eventData);

  @override
  List<Object?> get props => [eventId, eventData];
}

class DeleteEventRequested extends HeadEvent {
  final String eventId;

  const DeleteEventRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class FetchClubManageEvents extends HeadEvent {
  final String clubId;

  const FetchClubManageEvents(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

