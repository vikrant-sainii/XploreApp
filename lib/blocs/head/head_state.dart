import 'package:equatable/equatable.dart';
import '../../models/club_model.dart';
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
  final List<EventModel> events;
  final List<ClubMembershipModel> members;

  const HeadDashboardLoaded(
    this.stats, {
    this.events = const [],
    this.members = const [],
  });

  HeadDashboardLoaded copyWith({
    Map<String, dynamic>? stats,
    List<EventModel>? events,
    List<ClubMembershipModel>? members,
  }) {
    return HeadDashboardLoaded(
      stats ?? this.stats,
      events: events ?? this.events,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [stats, events, members];
}

class HeadActionSuccess extends HeadState {
  final String message;

  const HeadActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class HeadAttendanceSuccess extends HeadState {
  final String message;
  final Map<String, dynamic>? participant;

  const HeadAttendanceSuccess(this.message, {this.participant});

  @override
  List<Object?> get props => [message, participant];
}

class HeadError extends HeadState {
  final String message;

  const HeadError(this.message);

  @override
  List<Object?> get props => [message];
}
