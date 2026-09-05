import 'package:flutter_test/flutter_test.dart';
import 'package:xplore_app/blocs/event/event_bloc.dart';
import 'package:xplore_app/blocs/club/club_bloc.dart';
import 'package:xplore_app/blocs/head/head_bloc.dart';
import 'package:xplore_app/blocs/notification/notification_bloc.dart';

void main() {
  group('BLoC State Machine Tests', () {
    test('EventBloc emits EventsLoaded on FetchAllEvents', () async {
      final eventBloc = EventBloc();
      eventBloc.add(const FetchAllEvents());

      await expectLater(
        eventBloc.stream,
        emitsInOrder([
          isA<EventLoading>(),
          isA<EventsLoaded>(),
        ]),
      );
      eventBloc.close();
    });

    test('ClubBloc emits ClubsLoaded on FetchUserClubs', () async {
      final clubBloc = ClubBloc();
      clubBloc.add(const FetchUserClubs());

      await expectLater(
        clubBloc.stream,
        emitsInOrder([
          isA<ClubLoading>(),
          isA<ClubsLoaded>(),
        ]),
      );
      clubBloc.close();
    });

    test('HeadBloc emits HeadDashboardLoaded on FetchDashboardStats', () async {
      final headBloc = HeadBloc();
      headBloc.add(const FetchDashboardStats());

      await expectLater(
        headBloc.stream,
        emitsInOrder([
          isA<HeadLoading>(),
          isA<HeadDashboardLoaded>(),
        ]),
      );
      headBloc.close();
    });

    test('NotificationBloc emits NotificationsLoaded on FetchNotifications', () async {
      final notifBloc = NotificationBloc();
      notifBloc.add(const FetchNotifications());

      await expectLater(
        notifBloc.stream,
        emitsInOrder([
          isA<NotificationLoading>(),
          isA<NotificationsLoaded>(),
        ]),
      );
      notifBloc.close();
    });
  });
}
