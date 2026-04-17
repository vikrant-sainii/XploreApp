import 'package:equatable/equatable.dart';

// Dummy model to represent club data
class ClubModel extends Equatable {
  final String id;
  final String name;
  final String role; // "HEAD" or "MEMBER"
  final String image;

  const ClubModel({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
  });

  @override
  List<Object?> get props => [id, name, role, image];
}

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
