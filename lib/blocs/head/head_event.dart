import 'package:equatable/equatable.dart';

abstract class HeadEvent extends Equatable {
  const HeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardStats extends HeadEvent {}
