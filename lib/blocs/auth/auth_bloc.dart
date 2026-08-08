import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    // ─── Student login ──────────────────────────────────────────────────────
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.loginStudent(event.email, event.password);
        _handleAuthResult(result, emit);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── Admin login ────────────────────────────────────────────────────────
    on<AdminLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.loginAdmin(event.email, event.password);
        _handleAuthResult(result, emit);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── Student registration ────────────────────────────────────────────────
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = UserModel(
          id: '',
          name: event.name,
          email: event.email,
          role: 'member',
          rollNo: event.rollNo.isEmpty ? null : event.rollNo,
          branch: event.branch.isEmpty ? null : event.branch,
          year: event.year.isEmpty ? null : event.year,
          program: event.program.isEmpty ? 'BTECH' : event.program,
        );
        final result = await _authService.registerStudent(user, event.password);

        if (result['success'] == true) {
          // Dev mode: backend auto-logs in and returns user + token
          if (result['needs2FA'] == false && result['user'] is UserModel) {
            final role = result['role'] as String? ?? 'member';
            print("Successfully registered and auto-logged in! User role: $role");
            emit(Authenticated(result['user'] as UserModel, role: role));
          } else {
            // Production: user must verify email first
            emit(RegisterSuccess(
              result['message'] as String? ??
                  'Registration successful. Please check your email.',
            ));
          }
        } else {
          emit(AuthError(result['message'] as String? ?? 'Registration failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── External registration (OTP) ─────────────────────────────────────────
    on<RegisterExternalRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result =
            await _authService.registerExternal(event.name, event.email);
        if (result['success'] == true) {
          emit(ExternalOtpSent(
            email: result['email'] as String? ?? event.email,
            message: result['message'] as String? ?? 'OTP sent to your email.',
          ));
        } else {
          emit(AuthError(result['message'] as String? ?? 'Failed to send OTP'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── External login (OTP) ────────────────────────────────────────────────
    on<LoginExternalRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result =
            await _authService.loginExternal(event.email, event.otp);
        _handleAuthResult(result, emit);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── 2FA verification ────────────────────────────────────────────────────
    on<Verify2FARequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.verify2FA(event.email, event.otp);
        _handleAuthResult(result, emit);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── Logout ──────────────────────────────────────────────────────────────
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await _authService.logout();
      emit(Unauthenticated());
    });

    // ─── Forgot password ─────────────────────────────────────────────────────
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.forgotPassword(event.email);
        if (result['success'] == true) {
          emit(AuthForgotPasswordLinkSent());
        } else {
          emit(AuthError(result['message'] as String? ?? 'Failed to send reset link'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── Reset password ───────────────────────────────────────────────────────
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result =
            await _authService.resetPassword(event.token, event.newPassword);
        if (result['success'] == true) {
          emit(AuthPasswordResetSuccess());
        } else {
          emit(AuthError(result['message'] as String? ?? 'Failed to reset password'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── Change password ──────────────────────────────────────────────────────
    on<ChangePasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.changePassword(
            event.currentPassword, event.newPassword);
        if (result['success'] == true) {
          emit(AuthPasswordChangeSuccess());
        } else {
          emit(AuthError(result['message'] as String? ?? 'Failed to change password'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // ─── Email verification ───────────────────────────────────────────────────
    on<VerifyEmailRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.verifyEmail(event.token);
        if (result['success'] == true) {
          emit(EmailVerificationSuccess());
        } else {
          emit(AuthError(result['message'] as String? ?? 'Email verification failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }

  // ─── Shared result handler ────────────────────────────────────────────────
  void _handleAuthResult(
      Map<String, dynamic> result, Emitter<AuthState> emit) {
    if (result['success'] != true) {
      emit(AuthError(result['message'] as String? ?? 'An error occurred'));
      return;
    }
    if (result['needs2FA'] == true) {
      emit(Needs2FA(
        email: result['email'] as String? ?? '',
        message: result['message'] as String? ?? 'OTP sent to your email.',
      ));
      return;
    }
    final user = result['user'] as UserModel?;
    if (user != null) {
      final role = result['role'] as String? ?? user.role;
      print("SUCCESSFULLY LOGGED IN! User role on terminal: $role");
      emit(Authenticated(user, role: role));
    } else {
      emit(const AuthError('Unexpected response from server'));
    }
  }
}
