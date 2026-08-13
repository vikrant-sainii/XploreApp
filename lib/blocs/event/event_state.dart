import 'package:equatable/equatable.dart';
import '../../models/event_model.dart';

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

class EventOperationSuccess extends EventState {
  final String message;
  final String? qrCode;
  final String actionType; // 'register' or 'deregister'

  const EventOperationSuccess({
    required this.message,
    this.qrCode,
    required this.actionType,
  });

  @override
  List<Object?> get props => [message, qrCode, actionType];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

