import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {}

class FetchSentNotifications extends NotificationEvent {}

class SendNotificationRequested extends NotificationEvent {
  final String targetType;
  final String? eventId;
  final String title;
  final String message;

  const SendNotificationRequested({
    required this.targetType,
    this.eventId,
    required this.title,
    required this.message,
  });

  @override
  List<Object?> get props => [targetType, eventId, title, message];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}
