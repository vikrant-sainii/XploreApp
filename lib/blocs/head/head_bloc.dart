import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_service.dart';
import 'head_event.dart';
import 'head_state.dart';

export 'head_event.dart';
export 'head_state.dart';

class HeadBloc extends Bloc<HeadEvent, HeadState> {
  final AdminService _adminService;

  HeadBloc({AdminService? adminService})
      : _adminService = adminService ?? AdminService(),
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
  }
}
