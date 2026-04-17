import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageLocation;
  final bool isRegistered;

  const EventModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageLocation,
    required this.isRegistered,
  });

  @override
  List<Object?> get props => [id, title, subtitle, imageLocation, isRegistered];
}

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

  const EventsLoaded({
    required this.registeredEvents,
    required this.upcomingEvents,
  });

  @override
  List<Object?> get props => [registeredEvents, upcomingEvents];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}
