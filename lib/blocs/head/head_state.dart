import 'package:equatable/equatable.dart';

abstract class HeadState extends Equatable {
  const HeadState();
  
  @override
  List<Object?> get props => [];
}

class HeadInitial extends HeadState {}

class HeadLoading extends HeadState {}

class HeadDashboardLoaded extends HeadState {
  final Map<String, dynamic> stats; // Dummy payload
  
  const HeadDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class HeadError extends HeadState {
  final String message;

  const HeadError(this.message);

  @override
  List<Object?> get props => [message];
}
