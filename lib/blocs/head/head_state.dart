import 'package:equatable/equatable.dart';

import '../../models/event_model.dart';

abstract class HeadState extends Equatable {
  const HeadState();
  
  @override
  List<Object?> get props => [];
}

class HeadInitial extends HeadState {}

class HeadLoading extends HeadState {}

class HeadDashboardLoaded extends HeadState {
  final Map<String, dynamic> stats;
  
  const HeadDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class HeadManagedEventsLoaded extends HeadState {
  final List<EventModel> events;

  const HeadManagedEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class HeadEventOperationSuccess extends HeadState {
  final String message;
  final String actionType; // 'create', 'update', 'delete'
  final EventModel? event;

  const HeadEventOperationSuccess({
    required this.message,
    required this.actionType,
    this.event,
  });

  @override
  List<Object?> get props => [message, actionType, event];
}

class HeadError extends HeadState {
  final String message;

  const HeadError(this.message);

  @override
  List<Object?> get props => [message];
}

