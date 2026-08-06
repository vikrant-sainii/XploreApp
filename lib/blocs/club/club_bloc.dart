import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/club_service.dart';
import 'club_event.dart';
import 'club_state.dart';

export 'club_event.dart';
export 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ClubService _clubService;

  ClubBloc({ClubService? clubService})
      : _clubService = clubService ?? ClubService(),
        super(ClubInitial()) {
    on<FetchUserClubs>((event, emit) async {
      emit(ClubLoading());
      try {
        final clubs = await _clubService.getClubs();
        emit(ClubsLoaded(clubs));
      } catch (e) {
        emit(ClubError(e.toString()));
      }
    });
  }
}
