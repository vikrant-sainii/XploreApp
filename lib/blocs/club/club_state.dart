import 'package:equatable/equatable.dart';
import '../../models/club_model.dart';
import '../../models/event_model.dart';

export '../../models/club_model.dart';

abstract class ClubState extends Equatable {
  const ClubState();

  @override
  List<Object?> get props => [];
}

class ClubInitial extends ClubState {}

class ClubLoading extends ClubState {}

class ClubsLoaded extends ClubState {
  final List<ClubModel> clubs; // user's joined clubs
  final List<ClubModel> allClubs; // all college clubs

  const ClubsLoaded(this.clubs, {this.allClubs = const []});

  @override
  List<Object?> get props => [clubs, allClubs];
}

class ClubDetailsLoaded extends ClubState {
  final ClubModel club;
  final List<EventModel> events;

  const ClubDetailsLoaded({required this.club, required this.events});

  @override
  List<Object?> get props => [club, events];
}

class ClubError extends ClubState {
  final String message;

  const ClubError(this.message);

  @override
  List<Object?> get props => [message];
}
