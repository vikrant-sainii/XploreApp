import 'package:equatable/equatable.dart';
import '../../models/club_model.dart';

abstract class ClubState extends Equatable {
  const ClubState();

  @override
  List<Object?> get props => [];
}

class ClubInitial extends ClubState {}

class ClubLoading extends ClubState {}

class ClubsLoaded extends ClubState {
  final List<ClubModel> clubs;

  const ClubsLoaded(this.clubs);

  @override
  List<Object?> get props => [clubs];
}

class ClubError extends ClubState {
  final String message;

  const ClubError(this.message);

  @override
  List<Object?> get props => [message];
}
