import 'package:equatable/equatable.dart';
import '../../models/event_model.dart';
import '../../models/participation_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventModel> registeredEvents;
  final List<EventModel> upcomingEvents;
  final List<ParticipationModel> userParticipations;
  final List<EventModel> allEvents;
  final List<EventModel> filteredEvents;

  const EventsLoaded({
    required this.registeredEvents,
    required this.upcomingEvents,
    this.userParticipations = const [],
    this.allEvents = const [],
    this.filteredEvents = const [],
  });

  EventsLoaded copyWith({
    List<EventModel>? registeredEvents,
    List<EventModel>? upcomingEvents,
    List<ParticipationModel>? userParticipations,
    List<EventModel>? allEvents,
    List<EventModel>? filteredEvents,
  }) {
    return EventsLoaded(
      registeredEvents: registeredEvents ?? this.registeredEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      userParticipations: userParticipations ?? this.userParticipations,
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
    );
  }

  @override
  List<Object?> get props => [registeredEvents, upcomingEvents, userParticipations, allEvents, filteredEvents];
}

class EventRegistrationSuccess extends EventState {
  final String message;
  final String? qrCode;
  final String status;

  const EventRegistrationSuccess(this.message, {this.qrCode, this.status = 'REGISTERED'});

  @override
  List<Object?> get props => [message, qrCode, status];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}
