import 'package:equatable/equatable.dart';
import '../../models/team_model.dart';

abstract class TeamState extends Equatable {
  const TeamState();

  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamRegistrationSuccess extends TeamState {
  final String teamId;
  final String status;
  final String message;

  const TeamRegistrationSuccess({
    required this.teamId,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [teamId, status, message];
}

class TeamDetailsLoaded extends TeamState {
  final TeamModel team;

  const TeamDetailsLoaded(this.team);

  @override
  List<Object?> get props => [team];
}

class TeamActionSuccess extends TeamState {
  final String message;
  final String? status;

  const TeamActionSuccess({required this.message, this.status});

  @override
  List<Object?> get props => [message, status];
}

class TeamError extends TeamState {
  final String message;

  const TeamError(this.message);

  @override
  List<Object?> get props => [message];
}
