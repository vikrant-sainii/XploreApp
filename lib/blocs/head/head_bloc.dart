import 'package:flutter_bloc/flutter_bloc.dart';
import 'head_event.dart';
import 'head_state.dart';

export 'head_event.dart';
export 'head_state.dart';

class HeadBloc extends Bloc<HeadEvent, HeadState> {
  HeadBloc() : super(HeadInitial()) {
    on<FetchDashboardStats>((event, emit) async {
      emit(HeadLoading());
      await Future.delayed(const Duration(seconds: 1)); // Mock fetch
      
      emit(const HeadDashboardLoaded({
        'totalMembers': 120,
        'upcomingEvents': 2,
      }));
    });
  }
}
