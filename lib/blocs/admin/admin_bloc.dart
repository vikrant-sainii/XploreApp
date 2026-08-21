import 'package:flutter/foundation.dart';
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
        super(const AdminDataState()) {
    // ─── Dashboard Stats ────────────────────────────────────────────────────
    on<FetchAdminDashboardStats>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final result = await _adminService.getDashboardStats();
        if (result['success'] == true) {
          final stats = result['stats'] as Map<String, dynamic>;
          emit(current.copyWith(
            isLoading: false,
            stats: stats,
          ));
        } else {
          final msg = result['message'] ?? 'Failed to load dashboard stats';
          debugPrint('❌ [AdminBloc] FetchAdminDashboardStats failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminDashboardStats exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Events ─────────────────────────────────────────────────────────────
    on<FetchAdminEvents>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final events = await _adminService.getEventData(filters: event.filters);
        emit(current.copyWith(
          isLoading: false,
          events: events,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminEvents exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Clubs ──────────────────────────────────────────────────────────────
    on<FetchAdminClubs>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final clubs = await _adminService.getClubsList();
        emit(current.copyWith(
          isLoading: false,
          clubs: clubs,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminClubs exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<CreateAdminClub>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.createClub(event.clubData);
        if (result['success'] == true) {
          final clubs = await _adminService.getClubsList();
          emit(current.copyWith(
            isLoading: false,
            clubs: clubs,
            successMessage: 'Club created successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to create club';
          debugPrint('❌ [AdminBloc] CreateAdminClub failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] CreateAdminClub exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<UpdateAdminClub>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.updateClub(event.clubId, event.clubData);
        if (result['success'] == true) {
          final clubs = await _adminService.getClubsList();
          emit(current.copyWith(
            isLoading: false,
            clubs: clubs,
            successMessage: 'Club updated successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to update club';
          debugPrint('❌ [AdminBloc] UpdateAdminClub failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] UpdateAdminClub exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Coordinators ───────────────────────────────────────────────────────
    on<FetchAdminCoordinators>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final coordinators = await _adminService.getCoordinators();
        emit(current.copyWith(
          isLoading: false,
          coordinators: coordinators,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminCoordinators exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<CreateAdminCoordinator>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.createCoordinator(event.coordinatorData);
        if (result['success'] == true) {
          final coordinators = await _adminService.getCoordinators();
          emit(current.copyWith(
            isLoading: false,
            coordinators: coordinators,
            successMessage: 'Coordinator added successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to add coordinator';
          debugPrint('❌ [AdminBloc] CreateAdminCoordinator failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] CreateAdminCoordinator exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Payments ───────────────────────────────────────────────────────────
    on<FetchAdminPayments>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final result = await _adminService.getManualPaymentsWithSummary();
        emit(current.copyWith(
          isLoading: false,
          payments: result['participations'] as List<dynamic>? ?? [],
          paymentsSummary: result['summary'] as Map<String, dynamic>?,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminPayments exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Venues ─────────────────────────────────────────────────────────────
    on<FetchAdminVenues>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final venues = await _adminService.getVenues();
        emit(current.copyWith(
          isLoading: false,
          venues: venues,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminVenues exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<CreateAdminVenue>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.createVenue(event.venueData);
        if (result['success'] == true) {
          final venues = await _adminService.getVenues();
          emit(current.copyWith(
            isLoading: false,
            venues: venues,
            successMessage: 'Venue created successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to create venue';
          debugPrint('❌ [AdminBloc] CreateAdminVenue failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] CreateAdminVenue exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<UpdateAdminVenue>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.updateVenue(event.venueId, event.venueData);
        if (result['success'] == true) {
          final venues = await _adminService.getVenues();
          emit(current.copyWith(
            isLoading: false,
            venues: venues,
            successMessage: 'Venue updated successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to update venue';
          debugPrint('❌ [AdminBloc] UpdateAdminVenue failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] UpdateAdminVenue exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<DeleteAdminVenue>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.deleteVenue(event.venueId);
        if (result['success'] == true) {
          final venues = await _adminService.getVenues();
          emit(current.copyWith(
            isLoading: false,
            venues: venues,
            successMessage: 'Venue deleted successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to delete venue';
          debugPrint('❌ [AdminBloc] DeleteAdminVenue failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] DeleteAdminVenue exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Broadcasts ─────────────────────────────────────────────────────────
    on<FetchAdminBroadcasts>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final broadcasts = await _adminService.getSentBroadcasts();
        emit(current.copyWith(
          isLoading: false,
          broadcasts: broadcasts,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminBroadcasts exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<SendAdminBroadcast>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true));
      try {
        final result = await _adminService.sendBroadcast(event.broadcastData);
        if (result['success'] == true) {
          final broadcasts = await _adminService.getSentBroadcasts();
          emit(current.copyWith(
            isLoading: false,
            broadcasts: broadcasts,
            successMessage: 'Broadcast sent successfully!',
          ));
        } else {
          final msg = result['message'] ?? 'Failed to send broadcast';
          debugPrint('❌ [AdminBloc] SendAdminBroadcast failed: $msg');
          emit(current.copyWith(
            isLoading: false,
            errorMessage: msg,
          ));
        }
      } catch (e) {
        debugPrint('💥 [AdminBloc] SendAdminBroadcast exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // ─── Notifications ──────────────────────────────────────────────────────
    on<FetchAdminNotifications>((event, emit) async {
      final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
      emit(current.copyWith(isLoading: true, errorMessage: null));
      try {
        final notifications = await _adminService.getAdminNotifications();
        emit(current.copyWith(
          isLoading: false,
          notifications: notifications,
        ));
      } catch (e) {
        debugPrint('💥 [AdminBloc] FetchAdminNotifications exception: $e');
        emit(current.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<MarkAllAdminNotificationsRead>((event, emit) async {
      try {
        await _adminService.markAllNotificationsRead();
        final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
        emit(current.copyWith(successMessage: 'All notifications marked as read'));
      } catch (e) {
        debugPrint('💥 [AdminBloc] MarkAllAdminNotificationsRead exception: $e');
        final current = state is AdminDataState ? (state as AdminDataState) : const AdminDataState();
        emit(current.copyWith(errorMessage: e.toString()));
      }
    });
  }
}
