import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/lost_found_service.dart';
import 'lost_found_event.dart';
import 'lost_found_state.dart';

export 'lost_found_event.dart';
export 'lost_found_state.dart';

class LostFoundBloc extends Bloc<LostFoundEvent, LostFoundState> {
  final LostFoundService _lostFoundService;

  LostFoundBloc({LostFoundService? lostFoundService})
      : _lostFoundService = lostFoundService ?? LostFoundService(),
        super(LostFoundInitial()) {

    on<FetchLostFoundItems>((event, emit) async {
      emit(LostFoundLoading());
      try {
        final items = await _lostFoundService.getItems();
        emit(LostFoundItemsLoaded(items));
      } catch (e) {
        emit(LostFoundError(e.toString()));
      }
    });

    on<FetchMyLostFoundPosts>((event, emit) async {
      emit(LostFoundLoading());
      try {
        final posts = await _lostFoundService.getMyPosts();
        emit(MyLostFoundPostsLoaded(posts));
      } catch (e) {
        emit(LostFoundError(e.toString()));
      }
    });

    on<CreateLostFoundPost>((event, emit) async {
      emit(LostFoundLoading());
      try {
        final result = await _lostFoundService.createPost(
          title: event.title,
          description: event.description,
          type: event.type,
          imageUrl: event.imageUrl,
          imagePublicId: event.imagePublicId,
          whatsapp: event.whatsapp,
        );
        if (result['success'] == true) {
          emit(LostFoundPostCreated(
            post: result['post'],
            message: result['message'] ?? 'Post created successfully',
          ));
        } else {
          emit(LostFoundError(result['message'] ?? 'Failed to create post'));
        }
      } catch (e) {
        emit(LostFoundError(e.toString()));
      }
    });

    on<ReuniteItem>((event, emit) async {
      emit(LostFoundLoading());
      try {
        final result = await _lostFoundService.reunite(event.itemId);
        if (result['success'] == true) {
          emit(LostFoundActionSuccess(result['message'] ?? 'Item marked as reunited'));
        } else {
          emit(LostFoundError(result['message'] ?? 'Failed to mark item as reunited'));
        }
      } catch (e) {
        emit(LostFoundError(e.toString()));
      }
    });

    on<ReportLostFoundPost>((event, emit) async {
      emit(LostFoundLoading());
      try {
        final result = await _lostFoundService.reportPost(event.itemId, event.reason);
        if (result['success'] == true) {
          emit(LostFoundActionSuccess(result['message'] ?? 'Report submitted successfully'));
        } else {
          emit(LostFoundError(result['message'] ?? 'Failed to submit report'));
        }
      } catch (e) {
        emit(LostFoundError(e.toString()));
      }
    });

    on<ClaimLostFoundItem>((event, emit) async {
      emit(LostFoundLoading());
      try {
        final result = await _lostFoundService.claimPost(event.itemId);
        if (result['success'] == true) {
          emit(LostFoundClaimSuccess(
            message: result['message'] ?? 'Claim requested successfully',
            contact: result['contact'],
          ));
        } else {
          emit(LostFoundError(result['message'] ?? 'Failed to request claim'));
        }
      } catch (e) {
        emit(LostFoundError(e.toString()));
      }
    });
  }
}
