import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/event_model.dart';
import '../../models/participation_model.dart';
import '../../services/event_service.dart';
import 'event_event.dart';
import 'event_state.dart';

export 'event_event.dart';
export 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventService _eventService;
  String? _activeUserId;

  EventBloc({EventService? eventService})
      : _eventService = eventService ?? EventService(),
        super(EventInitial()) {
    on<FetchAllEvents>((event, emit) async {
      if (event.userId != null && event.userId!.isNotEmpty) {
        _activeUserId = event.userId;
      }

      // If we don't have previous events loaded, emit loading
      if (state is! EventsLoaded) {
        emit(EventLoading());
      }

      try {
        final events = await _eventService.getAllEvents();

        List<ParticipationModel> participations = [];
        final userIdToFetch = event.userId ?? _activeUserId;
        if (userIdToFetch != null && userIdToFetch.isNotEmpty) {
          try {
            participations = await _eventService.getUserParticipations(userIdToFetch);
          } catch (_) {}
        }

        final registeredIds = participations
            .map((p) => p.event?.id ?? p.eventId)
            .where((id) => id != null && id.isNotEmpty)
            .toSet();

        final Map<String, EventModel> registeredMap = {};
        for (var p in participations) {
          if (p.event != null) {
            registeredMap[p.event!.id] = p.event!.copyWith(isRegistered: true);
          }
        }
        for (var e in events) {
          if (registeredIds.contains(e.id)) {
            registeredMap[e.id] = e.copyWith(isRegistered: true);
          }
        }

        final upcoming = events.where((e) => e.status != 'COMPLETED').toList();
        final registered = registeredMap.values.toList();

        emit(EventsLoaded(
          registeredEvents: registered,
          upcomingEvents: upcoming,
          userParticipations: participations,
          allEvents: events,
          filteredEvents: upcoming,
        ));
      } catch (e) {
        // Fallback sample data if server is offline
        final fallbackUpcoming = [
          const EventModel(
            id: '1',
            title: 'GDGC CLUB Workshop',
            venue: 'A3, Civil Building',
            imageUrl: 'assets/gdgc.png',
            status: 'UPCOMING',
          ),
          const EventModel(
            id: '2',
            title: 'Octave Music Night',
            venue: 'Auditorium',
            imageUrl: 'assets/octave.png',
            status: 'UPCOMING',
          ),
          const EventModel(
            id: '3',
            title: 'Bhangra Workshop',
            venue: 'Open Air Theatre',
            imageUrl: 'assets/bhangralogo.png',
            status: 'UPCOMING',
          ),
        ];

        final fallbackRegistered = [
          const EventModel(
            id: '1',
            title: 'GDGC CLUB Workshop',
            venue: 'A3, Civil Building',
            imageUrl: 'assets/gdgc.png',
            isRegistered: true,
          ),
        ];

        emit(EventsLoaded(
          registeredEvents: fallbackRegistered,
          upcomingEvents: fallbackUpcoming,
          allEvents: fallbackUpcoming,
          filteredEvents: fallbackUpcoming,
        ));
      }
    });

    on<FetchUserParticipations>((event, emit) async {
      _activeUserId = event.userId;
      try {
        final participations = await _eventService.getUserParticipations(event.userId);
        final registeredEvents = participations.where((p) => p.event != null).map((p) => p.event!).toList();

        if (state is EventsLoaded) {
          final current = state as EventsLoaded;
          emit(current.copyWith(
            userParticipations: participations,
            registeredEvents: registeredEvents.isNotEmpty ? registeredEvents : current.registeredEvents,
          ));
        }
      } catch (_) {}
    });

    on<RegisterEventRequested>((event, emit) async {
      emit(EventLoading());
      try {
        final result = await _eventService.registerForEvent(
          event.eventId,
          externalEmail: event.externalEmail,
          externalName: event.externalName,
          formResponses: event.formResponses,
        );

        final qrCode = result['qrCode']?.toString();
        final status = result['status']?.toString() ?? 'REGISTERED';
        final message = result['message']?.toString() ?? 'Registration successful!';

        emit(EventRegistrationSuccess(message, qrCode: qrCode, status: status));

        // Immediately refresh events & participations for the active user
        add(FetchAllEvents(userId: _activeUserId));
      } catch (e) {
        emit(EventError(e.toString().replaceAll('Exception: ', '')));
        // Re-emit loaded state so UI doesn't remain blank
        add(FetchAllEvents(userId: _activeUserId));
      }
    });

    on<DeregisterEventRequested>((event, emit) async {
      emit(EventLoading());
      try {
        await _eventService.deregisterFromEvent(event.eventId, event.studentId);
        add(FetchAllEvents(userId: event.studentId));
      } catch (e) {
        emit(EventError(e.toString().replaceAll('Exception: ', '')));
        add(FetchAllEvents(userId: event.studentId));
      }
    });

    on<SearchEvents>((event, emit) {
      if (state is EventsLoaded) {
        final current = state as EventsLoaded;
        final q = event.query.toLowerCase().trim();
        if (q.isEmpty) {
          emit(current.copyWith(filteredEvents: current.upcomingEvents));
        } else {
          final filtered = current.allEvents.where((e) {
            return e.title.toLowerCase().contains(q) ||
                (e.venue?.toLowerCase().contains(q) ?? false) ||
                (e.clubName.toLowerCase().contains(q));
          }).toList();
          emit(current.copyWith(filteredEvents: filtered));
        }
      }
    });
  }
}
