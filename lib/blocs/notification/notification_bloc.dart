import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

export 'notification_event.dart';
export 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService(),
        super(NotificationInitial()) {
    
    on<FetchNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final notifications = await _notificationService.getNotifications();
        emit(NotificationsLoaded(notifications));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    on<FetchSentNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final notifications = await _notificationService.getSentNotifications();
        emit(SentNotificationsLoaded(notifications));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    on<SendNotificationRequested>((event, emit) async {
      emit(NotificationLoading());
      try {
        final notification = await _notificationService.sendNotification(
          targetType: event.targetType,
          eventId: event.eventId,
          title: event.title,
          message: event.message,
        );
        emit(NotificationSendSuccess(notification));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    on<MarkNotificationAsRead>((event, emit) async {
      try {
        await _notificationService.markRead(event.notificationId);
        emit(const NotificationActionSuccess('Notification marked as read'));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    on<MarkAllNotificationsAsRead>((event, emit) async {
      emit(NotificationLoading());
      try {
        await _notificationService.markAllRead();
        emit(const NotificationActionSuccess('All notifications marked as read'));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });
  }
}
