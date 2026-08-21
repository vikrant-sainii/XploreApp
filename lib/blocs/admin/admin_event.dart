import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class FetchAdminDashboardStats extends AdminEvent {
  const FetchAdminDashboardStats();
}

class FetchAdminClubs extends AdminEvent {
  const FetchAdminClubs();
}

class CreateAdminClub extends AdminEvent {
  final Map<String, dynamic> clubData;
  const CreateAdminClub(this.clubData);
  @override
  List<Object?> get props => [clubData];
}

class UpdateAdminClub extends AdminEvent {
  final String clubId;
  final Map<String, dynamic> clubData;
  const UpdateAdminClub(this.clubId, this.clubData);
  @override
  List<Object?> get props => [clubId, clubData];
}

class FetchAdminCoordinators extends AdminEvent {
  const FetchAdminCoordinators();
}

class CreateAdminCoordinator extends AdminEvent {
  final Map<String, dynamic> coordinatorData;
  const CreateAdminCoordinator(this.coordinatorData);
  @override
  List<Object?> get props => [coordinatorData];
}

class FetchAdminPayments extends AdminEvent {
  const FetchAdminPayments();
}

class FetchAdminVenues extends AdminEvent {
  const FetchAdminVenues();
}

class CreateAdminVenue extends AdminEvent {
  final Map<String, dynamic> venueData;
  const CreateAdminVenue(this.venueData);
  @override
  List<Object?> get props => [venueData];
}

class UpdateAdminVenue extends AdminEvent {
  final String venueId;
  final Map<String, dynamic> venueData;
  const UpdateAdminVenue(this.venueId, this.venueData);
  @override
  List<Object?> get props => [venueId, venueData];
}

class DeleteAdminVenue extends AdminEvent {
  final String venueId;
  const DeleteAdminVenue(this.venueId);
  @override
  List<Object?> get props => [venueId];
}

class FetchAdminBroadcasts extends AdminEvent {
  const FetchAdminBroadcasts();
}

class SendAdminBroadcast extends AdminEvent {
  final Map<String, dynamic> broadcastData;
  const SendAdminBroadcast(this.broadcastData);
  @override
  List<Object?> get props => [broadcastData];
}

class FetchAdminNotifications extends AdminEvent {
  const FetchAdminNotifications();
}

class MarkAllAdminNotificationsRead extends AdminEvent {
  const MarkAllAdminNotificationsRead();
}

class FetchAdminEvents extends AdminEvent {
  final Map<String, String>? filters;
  const FetchAdminEvents({this.filters});
  @override
  List<Object?> get props => [filters];
}
