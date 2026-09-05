import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class ClubEvent extends Equatable {
  const ClubEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserClubs extends ClubEvent {
  final UserModel? user;

  const FetchUserClubs({this.user});

  @override
  List<Object?> get props => [user];
}

class FetchAllClubs extends ClubEvent {}

class FetchClubDetails extends ClubEvent {
  final String clubId;

  const FetchClubDetails(this.clubId);

  @override
  List<Object?> get props => [clubId];
}
