import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_service.dart';
import 'admin_event.dart';
import 'admin_state.dart';

export 'admin_event.dart';
export 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminService _adminService;

  AdminBloc({AdminService? adminService})
      : _adminService = adminService ?? AdminService(),
        super(AdminInitial()) {
    on<FetchAdminStats>((event, emit) async {
      emit(AdminLoading());
      try {
        final stats = await _adminService.getDashboardStats();
        final exportData = await _adminService.getEventDataExport();
        emit(AdminDashboardLoaded(stats: stats, exportEvents: exportData));
      } catch (e) {
        // Fallback for offline or mock mode
        emit(const AdminDashboardLoaded(
          stats: {
            'totalRevenue': 24000,
            'totalStudents': 870,
            'totalClubs': 25,
            'totalEvents': 18,
            'totalEventsTillNow': 102,
          },
        ));
      }
    });

    on<FetchAdminClubs>((event, emit) async {
      emit(AdminLoading());
      try {
        final list = await _adminService.getClubsList();
        emit(AdminClubsLoaded(list));
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CreateAdminClubRequested>((event, emit) async {
      emit(AdminLoading());
      try {
        final res = await _adminService.createClub(
          clubName: event.clubName,
          facultyName: event.facultyName,
          facultyEmail: event.facultyEmail,
          clubEmail: event.clubEmail,
        );
        emit(AdminActionSuccess(res['message']?.toString() ?? 'Club created successfully!'));
        add(const FetchAdminClubs());
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateAdminClubRequested>((event, emit) async {
      try {
        final res = await _adminService.updateClub(event.id, event.data);
        emit(AdminActionSuccess(res['message']?.toString() ?? 'Club updated successfully!'));
        add(const FetchAdminClubs());
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<FetchCoordinatorsRequested>((event, emit) async {
      emit(AdminLoading());
      try {
        final list = await _adminService.getCoordinators();
        emit(AdminCoordinatorsLoaded(list));
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CreateCoordinatorRequested>((event, emit) async {
      emit(AdminLoading());
      try {
        final res = await _adminService.createCoordinator(
          name: event.name,
          email: event.email,
          password: event.password,
        );
        emit(AdminActionSuccess(res['message']?.toString() ?? 'Coordinator created!'));
        add(const FetchCoordinatorsRequested());
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateCoordinatorRequested>((event, emit) async {
      try {
        final res = await _adminService.updateCoordinator(event.id, event.data);
        emit(AdminActionSuccess(res['message']?.toString() ?? 'Coordinator updated!'));
        add(const FetchCoordinatorsRequested());
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CompletePayoutRequested>((event, emit) async {
      try {
        final res = await _adminService.completePayout(event.eventId);
        emit(AdminActionSuccess(res['message']?.toString() ?? 'Payout completed!'));
        add(const FetchAdminStats());
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<FetchExportDataRequested>((event, emit) async {
      emit(AdminLoading());
      try {
        final list = await _adminService.getEventDataExport(
          month: event.month,
          year: event.year,
          clubId: event.clubId,
        );
        emit(AdminExportLoaded(list));
      } catch (e) {
        emit(AdminError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
