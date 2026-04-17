import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_event.dart';
import 'event_state.dart';

export 'event_event.dart';
export 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc() : super(EventInitial()) {
    on<FetchAllEvents>((event, emit) async {
      emit(EventLoading());
      await Future.delayed(const Duration(seconds: 1)); // Mock network delay
      
      final mockRegistered = [
        const EventModel(
          id: '1', 
          title: 'GDGC CLUB Workshop', 
          subtitle: 'Free Workshop', 
          imageLocation: 'assets/gdgc.png',
          isRegistered: true,
        ),
        const EventModel(
          id: '2', 
          title: 'GDGC CLUB Workshop', 
          subtitle: 'Free Workshop', 
          imageLocation: 'assets/gdgc.png',
          isRegistered: true,
        ),
        const EventModel(
          id: '3', 
          title: 'GDGC CLUB Workshop', 
          subtitle: 'Free Workshop', 
          imageLocation: 'assets/gdgc.png',
          isRegistered: true,
        ),    
      ];

      final mockUpcoming = [
        const EventModel(
          id: '1', 
          title: 'Octave', 
          subtitle: 'Venue : A3,Civil Building', 
          imageLocation: 'assets/octave.png',
          isRegistered: false,
        ),
        const EventModel(
          id: '2', 
          title: 'Octave', 
          subtitle: 'Venue : A3,Civil Building', 
          imageLocation: 'assets/octave.png',
          isRegistered: false,
        ),
        const EventModel(
          id: '3', 
          title: 'Octave', 
          subtitle: 'Venue : A3,Civil Building', 
          imageLocation: 'assets/octave.png',
          isRegistered: false,
        ),


      ];

      emit(EventsLoaded(
        registeredEvents: mockRegistered, 
        upcomingEvents: mockUpcoming
      ));
    });
  }
}
