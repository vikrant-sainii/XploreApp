import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

export 'notification_event.dart';
export 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;
  List<NotificationModel> _notifications = [];
  String? _userId;

  NotificationBloc({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService(),
        super(NotificationInitial()) {
    on<FetchNotifications>((event, emit) async {
      emit(NotificationLoading());
      if (event.userId != null) _userId = event.userId;
      try {
        final list = await _notificationService.getNotifications();
        _notifications = list;
        final unread = _userId != null
            ? list.where((n) => !n.isReadBy(_userId!)).length
            : list.where((n) => n.readBy.isEmpty).length;
        emit(NotificationsLoaded(list, unreadCount: unread));
      } catch (e) {
        // Fallback sample notification
        final sample = [
          NotificationModel(
            id: '1',
            title: 'Welcome to ClubSetu!',
            message: 'Discover, participate, and manage campus events seamlessly.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            sender: const {'clubName': 'Admin Team', 'email': 'admin@nitj.ac.in'},
          ),
        ];
        _notifications = sample;
        emit(NotificationsLoaded(sample, unreadCount: 1));
      }
    });

    on<MarkAllNotificationsRead>((event, emit) async {
      try {
        await _notificationService.markAllRead();
        if (_userId != null) {
          _notifications = _notifications.map((n) {
            final reads = List<String>.from(n.readBy);
            if (!reads.contains(_userId!)) reads.add(_userId!);
            return NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              createdAt: n.createdAt,
              readBy: reads,
              sender: n.sender,
            );
          }).toList();
        }
        emit(NotificationsLoaded(_notifications, unreadCount: 0));
      } catch (_) {
        emit(NotificationsLoaded(_notifications, unreadCount: 0));
      }
    });

    on<MarkNotificationAsRead>((event, emit) async {
      try {
        await _notificationService.markAsRead(event.id);
        if (_userId != null) {
          _notifications = _notifications.map((n) {
            if (n.id == event.id) {
              final reads = List<String>.from(n.readBy);
              if (!reads.contains(_userId!)) reads.add(_userId!);
              return NotificationModel(
                id: n.id,
                title: n.title,
                message: n.message,
                createdAt: n.createdAt,
                readBy: reads,
                sender: n.sender,
              );
            }
            return n;
          }).toList();
        }
        final unread = _userId != null
            ? _notifications.where((n) => !n.isReadBy(_userId!)).length
            : 0;
        emit(NotificationsLoaded(_notifications, unreadCount: unread));
      } catch (_) {}
    });
  }
}
