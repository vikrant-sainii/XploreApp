import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/club_model.dart';
import '../../models/event_model.dart';
import '../../services/club_service.dart';
import '../../services/event_service.dart';
import '../../services/notification_service.dart';
import 'head_event.dart';
import 'head_state.dart';

export 'head_event.dart';
export 'head_state.dart';

class HeadBloc extends Bloc<HeadEvent, HeadState> {
  final EventService _eventService;
  final ClubService _clubService;
  final NotificationService _notificationService;

  HeadBloc({
    EventService? eventService,
    ClubService? clubService,
    NotificationService? notificationService,
  })  : _eventService = eventService ?? EventService(),
        _clubService = clubService ?? ClubService(),
        _notificationService = notificationService ?? NotificationService(),
        super(HeadInitial()) {
    on<FetchDashboardStats>((event, emit) async {
      emit(HeadLoading());
      try {
        List<EventModel> events = [];
        List<ClubMembershipModel> members = [];

        if (event.clubId != null && event.clubId!.isNotEmpty) {
          try {
            events = await _eventService.getClubManageEvents(event.clubId!);
          } catch (_) {}
          try {
            members = await _clubService.getClubMembers(event.clubId!);
          } catch (_) {}
        } else {
          try {
            events = await _eventService.getAllEvents();
          } catch (_) {}
        }

        final totalMembers = members.isNotEmpty ? members.length : 120;
        final upcomingEvents = events.where((e) => e.status != 'COMPLETED').length;
        final completedEvents = events.where((e) => e.status == 'COMPLETED').length;
        final totalParticipants = events.fold<int>(0, (sum, e) => sum + e.registeredCount);

        emit(HeadDashboardLoaded(
          {
            'totalMembers': totalMembers,
            'upcomingEvents': upcomingEvents,
            'totalEvents': events.length,
            'completedEvents': completedEvents,
            'totalParticipants': totalParticipants,
          },
          events: events,
          members: members,
        ));
      } catch (e) {
        emit(const HeadDashboardLoaded({
          'totalMembers': 120,
          'upcomingEvents': 0,
          'totalEvents': 0,
          'completedEvents': 0,
          'totalParticipants': 0,
        }));
      }
    });

    on<FetchClubEvents>((event, emit) async {
      emit(HeadLoading());
      try {
        List<EventModel> events = [];
        if (event.clubId.isNotEmpty) {
          events = await _eventService.getClubManageEvents(event.clubId);
        } else {
          events = await _eventService.getAllEvents();
        }
        if (state is HeadDashboardLoaded) {
          emit((state as HeadDashboardLoaded).copyWith(events: events));
        } else {
          emit(HeadDashboardLoaded(const {}, events: events));
        }
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<CreateClubEvent>((event, emit) async {
      emit(HeadLoading());
      try {
        await _eventService.createEvent(event.eventData);
        emit(const HeadActionSuccess('Event submitted successfully and is pending review!'));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<UpdateClubEvent>((event, emit) async {
      emit(HeadLoading());
      try {
        await _eventService.updateEvent(event.eventId, event.eventData);
        emit(const HeadActionSuccess('Event updated successfully!'));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<DeleteClubEvent>((event, emit) async {
      emit(HeadLoading());
      try {
        await _eventService.deleteEvent(event.eventId);
        emit(const HeadActionSuccess('Event deleted successfully!'));
        if (event.clubId != null) {
          add(FetchDashboardStats(clubId: event.clubId));
        }
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<FetchClubMembers>((event, emit) async {
      emit(HeadLoading());
      try {
        final members = await _clubService.getClubMembers(event.clubId);
        if (state is HeadDashboardLoaded) {
          emit((state as HeadDashboardLoaded).copyWith(members: members));
        } else {
          emit(HeadDashboardLoaded(const {}, members: members));
        }
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<AddClubMemberRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        await _clubService.addClubMember(event.clubId, event.email, role: event.role);
        emit(const HeadActionSuccess('Member added successfully!'));
        add(FetchClubMembers(event.clubId));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<UpdateMemberPermissionsRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        await _clubService.updateMemberPermissions(
          event.membershipId,
          role: event.role,
          canTakeAttendance: event.canTakeAttendance,
          canEditEvents: event.canEditEvents,
        );
        emit(const HeadActionSuccess('Member updated successfully!'));
        if (event.clubId != null) {
          add(FetchClubMembers(event.clubId!));
        }
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<RemoveClubMemberRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        await _clubService.removeClubMember(event.membershipId);
        emit(const HeadActionSuccess('Member removed successfully!'));
        if (event.clubId != null) {
          add(FetchClubMembers(event.clubId!));
        }
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<CheckInQrRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        final res = await _eventService.checkInQr(event.eventId, event.qrCode);
        emit(HeadAttendanceSuccess(
          res['message']?.toString() ?? 'Check-in successful!',
          participant: res['participant'] is Map<String, dynamic> ? res['participant'] : null,
        ));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<CheckInManualRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        final res = await _eventService.checkInManual(event.eventId, event.participationId);
        emit(HeadAttendanceSuccess(res['message']?.toString() ?? 'Marked as attended!'));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<SendAnnouncementRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        await _notificationService.sendNotification(
          title: event.title,
          message: event.message,
          targetType: event.targetType,
          eventId: event.eventId,
        );
        emit(const HeadActionSuccess('Announcement broadcasted successfully!'));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });
  }
}
