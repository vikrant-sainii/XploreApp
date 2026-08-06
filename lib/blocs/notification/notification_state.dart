import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class SentNotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const SentNotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationSendSuccess extends NotificationState {
  final NotificationModel notification;

  const NotificationSendSuccess(this.notification);

  @override
  List<Object?> get props => [notification];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
