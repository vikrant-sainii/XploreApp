import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllEvents extends EventEvent {
  final String? userId;

  const FetchAllEvents({this.userId});

  @override
  List<Object?> get props => [userId];
}

class FetchUserParticipations extends EventEvent {
  final String userId;

  const FetchUserParticipations(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RegisterEventRequested extends EventEvent {
  final String eventId;
  final String? externalEmail;
  final String? externalName;
  final Map<String, dynamic>? formResponses;

  const RegisterEventRequested(
    this.eventId, {
    this.externalEmail,
    this.externalName,
    this.formResponses,
  });

  @override
  List<Object?> get props => [eventId, externalEmail, externalName, formResponses];
}

class DeregisterEventRequested extends EventEvent {
  final String eventId;
  final String studentId;

  const DeregisterEventRequested(this.eventId, this.studentId);

  @override
  List<Object?> get props => [eventId, studentId];
}

class SearchEvents extends EventEvent {
  final String query;

  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}
