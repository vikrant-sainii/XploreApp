import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/team_service.dart';
import 'team_event.dart';
import 'team_state.dart';

export 'team_event.dart';
export 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamService _teamService;

  TeamBloc({TeamService? teamService})
      : _teamService = teamService ?? TeamService(),
        super(TeamInitial()) {

    on<RegisterTeamRequested>((event, emit) async {
      emit(TeamLoading());
      try {
        final result = await _teamService.registerTeam({
          'eventId': event.eventId,
          'teamName': event.teamName,
          'members': event.memberIds,
          if (event.formResponses != null) 'formResponses': event.formResponses,
          if (event.transactionId != null) 'transactionId': event.transactionId,
          if (event.payerName != null) 'payerName': event.payerName,
          if (event.paymentRemarks != null) 'paymentRemarks': event.paymentRemarks,
        });
        if (result['success'] == true) {
          emit(TeamRegistrationSuccess(
            teamId: result['teamId'] ?? '',
            status: result['status'] ?? 'REGISTERED',
            message: result['message'] ?? 'Team registered successfully',
          ));
        } else {
          emit(TeamError(result['message'] ?? 'Team registration failed'));
        }
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<AcceptTeamInvitation>((event, emit) async {
      emit(TeamLoading());
      try {
        final result = await _teamService.acceptInvitation(event.notificationId);
        if (result['success'] == true) {
          emit(TeamActionSuccess(
            message: result['message'] ?? 'Invitation accepted',
            status: result['status'],
          ));
        } else {
          emit(TeamError(result['message'] ?? 'Failed to accept invitation'));
        }
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<DeclineTeamInvitation>((event, emit) async {
      emit(TeamLoading());
      try {
        final result = await _teamService.declineInvitation(event.notificationId);
        if (result['success'] == true) {
          emit(TeamActionSuccess(message: result['message'] ?? 'Invitation declined'));
        } else {
          emit(TeamError(result['message'] ?? 'Failed to decline invitation'));
        }
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<InviteTeamMember>((event, emit) async {
      emit(TeamLoading());
      try {
        final result = await _teamService.inviteMember(event.teamId, event.studentId);
        if (result['success'] == true) {
          emit(TeamActionSuccess(message: result['message'] ?? 'Teammate invited successfully'));
        } else {
          emit(TeamError(result['message'] ?? 'Failed to invite teammate'));
        }
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<FetchTeamDetails>((event, emit) async {
      emit(TeamLoading());
      try {
        final team = await _teamService.getTeamDetails(event.teamId);
        emit(TeamDetailsLoaded(team));
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });
  }
}
