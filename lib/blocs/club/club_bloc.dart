import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../services/club_service.dart';
import 'club_event.dart';
import 'club_state.dart';

export 'club_event.dart';
export 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ClubService _clubService;
  List<ClubModel> _allClubs = [];
  UserModel? _activeUser;
  List<ClubModel> get allClubs => _allClubs;

  ClubBloc({ClubService? clubService})
      : _clubService = clubService ?? ClubService(),
        super(ClubInitial()) {
    on<FetchUserClubs>((event, emit) async {
      _activeUser = event.user ?? _activeUser;
      emit(ClubLoading());
      try {
        final clubs = await _clubService.getAllClubs();
        _allClubs = clubs;

        List<ClubModel> userClubs = [];
        if (_activeUser != null && _activeUser!.memberships.isNotEmpty) {
          final Map<String, String> userClubMap = {};

          for (var m in _activeUser!.memberships) {
            userClubMap[m.clubId] = m.role;
          }
          if (_activeUser!.clubId != null &&
              _activeUser!.clubId!.isNotEmpty &&
              !userClubMap.containsKey(_activeUser!.clubId)) {
            userClubMap[_activeUser!.clubId!] = _activeUser!.role;
          }

          for (var club in clubs) {
            if (userClubMap.containsKey(club.id)) {
              final role = userClubMap[club.id] ?? 'MEMBER';
              userClubs.add(ClubModel(
                id: club.id,
                name: club.name,
                slug: club.slug,
                description: club.description,
                category: club.category,
                image: club.image ?? 'assets/gdgc.png',
                role: role == 'CLUB_HEAD' ? 'HEAD' : role,
                socialLinks: club.socialLinks,
                clubGallery: club.clubGallery,
                clubSponsors: club.clubSponsors,
              ));
            }
          }
        }

        emit(ClubsLoaded(userClubs, allClubs: clubs));
      } catch (e) {
        emit(ClubsLoaded([], allClubs: _allClubs));
      }
    });

    on<FetchAllClubs>((event, emit) async {
      try {
        final clubs = await _clubService.getAllClubs();
        _allClubs = clubs;
        if (state is ClubsLoaded) {
          final current = state as ClubsLoaded;
          emit(ClubsLoaded(current.clubs, allClubs: clubs));
        } else {
          emit(ClubsLoaded([], allClubs: clubs));
        }
      } catch (_) {}
    });

    on<FetchClubDetails>((event, emit) async {
      emit(ClubLoading());
      try {
        final details = await _clubService.getClubDetails(event.clubId);
        if (details['club'] != null) {
          final eventsList = (details['events'] is List)
              ? (details['events'] as List).whereType<EventModel>().toList()
              : <EventModel>[];
          emit(ClubDetailsLoaded(
            club: details['club'] as ClubModel,
            events: eventsList,
          ));
        } else {
          emit(const ClubError('Club not found'));
        }
      } catch (e) {
        emit(ClubError(e.toString()));
      }
    });
  }
}
