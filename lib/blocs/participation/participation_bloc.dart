import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/participation_service.dart';
import 'participation_event.dart';
import 'participation_state.dart';

export 'participation_event.dart';
export 'participation_state.dart';

class ParticipationBloc extends Bloc<ParticipationEvent, ParticipationState> {
  final ParticipationService _participationService;

  ParticipationBloc({ParticipationService? participationService})
      : _participationService = participationService ?? ParticipationService(),
        super(ParticipationInitial()) {
    
    on<VerifyQRAttendance>((event, emit) async {
      emit(ParticipationLoading());
      try {
        final result = await _participationService.verifyQR(event.qrCode);
        if (result['success'] == true) {
          emit(QRAttendanceSuccess(
            participantName: result['participantName'] ?? '',
            rollNo: result['rollNo'],
            externalEmail: result['externalEmail'],
            attendedAt: result['attendedAt'],
          ));
        } else {
          emit(ParticipationError(result['message'] ?? 'Failed to verify QR Code'));
        }
      } catch (e) {
        emit(ParticipationError(e.toString()));
      }
    });

    on<FetchEventRegistrations>((event, emit) async {
      emit(ParticipationLoading());
      try {
        final registrations = await _participationService.getEventRegistrations(event.eventId);
        emit(EventRegistrationsLoaded(registrations));
      } catch (e) {
        emit(ParticipationError(e.toString()));
      }
    });
  }
}
