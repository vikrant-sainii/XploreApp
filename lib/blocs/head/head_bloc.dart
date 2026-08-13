import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_service.dart';
import '../../services/event_service.dart';
import 'head_event.dart';
import 'head_state.dart';


export 'head_event.dart';
export 'head_state.dart';

class HeadBloc extends Bloc<HeadEvent, HeadState> {
  final AdminService _adminService;
  final EventService _eventService;

  HeadBloc({AdminService? adminService, EventService? eventService})
      : _adminService = adminService ?? AdminService(),
        _eventService = eventService ?? EventService(),
        super(HeadInitial()) {
    on<FetchDashboardStats>((event, emit) async {
      emit(HeadLoading());
      try {
        final result = await _adminService.getDashboardStats();
        if (result['success'] == true) {
          emit(HeadDashboardLoaded(result['stats'] as Map<String, dynamic>));
        } else {
          emit(HeadError(result['message'] ?? 'Failed to load dashboard stats'));
        }
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<FetchClubManageEvents>((event, emit) async {
      emit(HeadLoading());
      try {
        final events = await _eventService.getClubManageEvents(event.clubId);
        emit(HeadManagedEventsLoaded(events));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<CreateEventRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        final createdEvent = await _eventService.createEvent(event.eventData);
        emit(HeadEventOperationSuccess(
          message: 'Event created successfully!',
          actionType: 'create',
          event: createdEvent,
        ));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<UpdateEventRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        final updatedEvent = await _eventService.updateEvent(event.eventId, event.eventData);
        emit(HeadEventOperationSuccess(
          message: 'Event updated successfully!',
          actionType: 'update',
          event: updatedEvent,
        ));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });

    on<DeleteEventRequested>((event, emit) async {
      emit(HeadLoading());
      try {
        await _eventService.deleteEvent(event.eventId);
        emit(const HeadEventOperationSuccess(
          message: 'Event deleted successfully!',
          actionType: 'delete',
        ));
      } catch (e) {
        emit(HeadError(e.toString()));
      }
    });
  }
}

