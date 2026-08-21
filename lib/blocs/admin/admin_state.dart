import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminDataState extends AdminState {
  final bool isLoading;
  final Map<String, dynamic>? stats;
  final List<dynamic>? events;
  final List<dynamic>? clubs;
  final List<dynamic>? coordinators;
  final List<dynamic>? payments;
  final Map<String, dynamic>? paymentsSummary;
  final List<dynamic>? venues;
  final List<dynamic>? broadcasts;
  final List<dynamic>? notifications;
  final String? errorMessage;
  final String? successMessage;

  const AdminDataState({
    this.isLoading = false,
    this.stats,
    this.events,
    this.clubs,
    this.coordinators,
    this.payments,
    this.paymentsSummary,
    this.venues,
    this.broadcasts,
    this.notifications,
    this.errorMessage,
    this.successMessage,
  });

  AdminDataState copyWith({
    bool? isLoading,
    Map<String, dynamic>? stats,
    List<dynamic>? events,
    List<dynamic>? clubs,
    List<dynamic>? coordinators,
    List<dynamic>? payments,
    Map<String, dynamic>? paymentsSummary,
    List<dynamic>? venues,
    List<dynamic>? broadcasts,
    List<dynamic>? notifications,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminDataState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      events: events ?? this.events,
      clubs: clubs ?? this.clubs,
      coordinators: coordinators ?? this.coordinators,
      payments: payments ?? this.payments,
      paymentsSummary: paymentsSummary ?? this.paymentsSummary,
      venues: venues ?? this.venues,
      broadcasts: broadcasts ?? this.broadcasts,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        stats,
        events,
        clubs,
        coordinators,
        payments,
        paymentsSummary,
        venues,
        broadcasts,
        notifications,
        errorMessage,
        successMessage,
      ];
}

class AdminOperationSuccess extends AdminState {
  final String message;
  const AdminOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
