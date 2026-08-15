import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/event_service.dart';
import '../../services/user_service.dart';
import '../../models/event_model.dart';
import 'event_event.dart';
import 'event_state.dart';

export 'event_event.dart';
export 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventService _eventService;
  final UserService _userService;

  EventBloc({EventService? eventService, UserService? userService})
      : _eventService = eventService ?? EventService(),
        _userService = userService ?? UserService(),
        super(EventInitial()) {
    on<FetchAllEvents>((event, emit) async {
      emit(EventLoading());
      try {
        // 1. Fetch all published events
        final allEvents = await _eventService.getEvents();

        // 2. Fetch logged in user to get registered events
        final meResult = await _userService.getMe();
        List<EventModel> registered = [];
        List<EventModel> upcoming = [];

        if (meResult['success'] == true && meResult['user'] != null) {
          final user = meResult['user'];
          final participations = await _eventService.getUserRegisteredEvents(user.id);
          
          final registeredIds = participations.map((p) => p.eventId).toSet();
          
          // Extract the full EventModel from participations or match from allEvents
          for (var p in participations) {
            if (p.event != null) {
              registered.add(p.event!.copyWith(isRegistered: true));
            }
          }

          // If some events from participations aren't fully populated, cross-reference
          for (var ev in allEvents) {
            if (registeredIds.contains(ev.id)) {
              if (!registered.any((r) => r.id == ev.id)) {
                registered.add(ev.copyWith(isRegistered: true));
              }
            } else {
              upcoming.add(ev);
            }
          }
        } else {
          // Not logged in or guest: all events are upcoming
          upcoming = allEvents;
        }

        emit(EventsLoaded(
          registeredEvents: registered,
          upcomingEvents: upcoming,
        ));
      } catch (e) {
        emit(EventError(e.toString()));
      }
    });

    on<RegisterForEvent>((event, emit) async {
      EventsLoaded? previousState;
      if (state is EventsLoaded) {
        previousState = state as EventsLoaded;
      }

      try {
        final result = await _eventService.registerForEvent(
          event.eventId,
          externalEmail: event.externalEmail,
          externalName: event.externalName,
          transactionId: event.transactionId,
          payerName: event.payerName,
          paymentRemarks: event.paymentRemarks,
          formResponses: event.formResponses,
        );

        if (result['success'] == true) {
          emit(EventOperationSuccess(
            message: result['message'] ?? 'Registered successfully',
            qrCode: result['qrCode'],
            actionType: 'register',
          ));
          add(FetchAllEvents());
        } else {
          final errorMsg = result['message'] ?? 'Registration failed';
          emit(EventError(errorMsg));
          if (previousState != null) {
            emit(previousState);
          } else {
            add(FetchAllEvents());
          }
        }
      } catch (e) {
        emit(EventError(e.toString()));
        if (previousState != null) {
          emit(previousState);
        } else {
          add(FetchAllEvents());
        }
      }
    });

    on<DeregisterFromEvent>((event, emit) async {
      EventsLoaded? previousState;
      if (state is EventsLoaded) {
        previousState = state as EventsLoaded;
      }

      try {
        final result = await _eventService.deregisterFromEvent(
          event.eventId,
          event.studentId,
        );

        if (result['success'] == true) {
          emit(EventOperationSuccess(
            message: result['message'] ?? 'Deregistered successfully',
            actionType: 'deregister',
          ));
          add(FetchAllEvents());
        } else {
          final errorMsg = result['message'] ?? 'Deregistration failed';
          emit(EventError(errorMsg));
          if (previousState != null) {
            emit(previousState);
          } else {
            add(FetchAllEvents());
          }
        }
      } catch (e) {
        emit(EventError(e.toString()));
        if (previousState != null) {
          emit(previousState);
        } else {
          add(FetchAllEvents());
        }
      }
    });
  }
}

