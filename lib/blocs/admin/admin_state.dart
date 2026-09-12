import 'package:equatable/equatable.dart';
import '../../models/coordinator_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> exportEvents;

  const AdminDashboardLoaded({
    required this.stats,
    this.exportEvents = const [],
  });

  @override
  List<Object?> get props => [stats, exportEvents];
}

class AdminClubsLoaded extends AdminState {
  final List<Map<String, dynamic>> clubs;

  const AdminClubsLoaded(this.clubs);

  @override
  List<Object?> get props => [clubs];
}

class AdminCoordinatorsLoaded extends AdminState {
  final List<CoordinatorModel> coordinators;

  const AdminCoordinatorsLoaded(this.coordinators);

  @override
  List<Object?> get props => [coordinators];
}

class AdminExportLoaded extends AdminState {
  final List<Map<String, dynamic>> events;

  const AdminExportLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
