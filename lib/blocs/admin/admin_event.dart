import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminStats extends AdminEvent {
  const FetchAdminStats();
}

class FetchAdminClubs extends AdminEvent {
  const FetchAdminClubs();
}

class CreateAdminClubRequested extends AdminEvent {
  final String clubName;
  final String facultyName;
  final String facultyEmail;
  final String clubEmail;

  const CreateAdminClubRequested({
    required this.clubName,
    required this.facultyName,
    required this.facultyEmail,
    required this.clubEmail,
  });

  @override
  List<Object?> get props => [clubName, facultyName, facultyEmail, clubEmail];
}

class UpdateAdminClubRequested extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateAdminClubRequested(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class FetchCoordinatorsRequested extends AdminEvent {
  const FetchCoordinatorsRequested();
}

class CreateCoordinatorRequested extends AdminEvent {
  final String name;
  final String email;
  final String? password;

  const CreateCoordinatorRequested({
    required this.name,
    required this.email,
    this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class UpdateCoordinatorRequested extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateCoordinatorRequested(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class CompletePayoutRequested extends AdminEvent {
  final String eventId;

  const CompletePayoutRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class FetchExportDataRequested extends AdminEvent {
  final String? month;
  final String? year;
  final String? clubId;

  const FetchExportDataRequested({this.month, this.year, this.clubId});

  @override
  List<Object?> get props => [month, year, clubId];
}
