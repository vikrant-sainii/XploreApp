import 'package:flutter_bloc/flutter_bloc.dart';
import 'club_event.dart';
import 'club_state.dart';

export 'club_event.dart';
export 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  ClubBloc() : super(ClubInitial()) {
    on<FetchUserClubs>((event, emit) async {
      emit(ClubLoading());
      await Future.delayed(const Duration(seconds: 1)); // Mock fetch
      
      // Dummy data representing combinations of Head and Member roles
      final List<ClubModel> mockClubs = [
        const ClubModel(
          id: '1', 
          name: 'GDGC CLUB', 
          role: 'HEAD', 
          image: 'assets/gdgc.png'
        ),
        const ClubModel(
          id: '2', 
          name: 'OCTAVE CLUB', 
          role: 'MEMBER', 
          image: 'assets/octave.png'
        ),
        const ClubModel(
          id: '3', 
          name: 'BHANGRA CLUB', 
          role: 'MEMBER', 
          image: 'assets/bhangralogo.png'
        ),
      ];
      
      emit(ClubsLoaded(mockClubs));
    });
  }
}
