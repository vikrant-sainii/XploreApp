import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserService _userService;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthBloc({
    required AuthService authService,
    UserService? userService,
  })  : _authService = authService,
        _userService = userService ?? UserService(),
        super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _userService.getMe();
        _currentUser = user;
        emit(Authenticated(user));
      } catch (_) {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.login(event.email, event.password, isAdmin: event.isAdmin);

        if (result['success'] == true) {
          if (result['needs2FA'] == true) {
            emit(AuthNeeds2FA(result['email'] ?? event.email, result['message'] ?? 'Enter 2FA Code'));
            return;
          }

          try {
            final user = await _userService.getMe();
            _currentUser = user;
            emit(Authenticated(user));
          } catch (_) {
            final rawUser = result['data']?['admin'] ?? result['data']?['user'];
            Map<String, dynamic> userMap;
            if (rawUser is Map<String, dynamic> && rawUser.isNotEmpty) {
              userMap = Map<String, dynamic>.from(rawUser);
              if (!userMap.containsKey('role') && event.isAdmin) {
                userMap['role'] = 'admin';
              }
            } else {
              userMap = {
                'email': event.email,
                'name': event.email.split('@').first,
                'role': event.isAdmin ? 'admin' : 'member',
              };
            }
            final fallbackUser = UserModel.fromJson(userMap);
            _currentUser = fallbackUser;
            emit(Authenticated(fallbackUser));
          }
        } else {
          emit(AuthError(result['message'] ?? 'Login failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ExternalLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.loginExternal(event.email, event.otp);
        if (result['success'] == true) {
          try {
            final user = await _userService.getMe();
            _currentUser = user;
            emit(Authenticated(user));
          } catch (_) {
            final rawUser = result['data']?['user'] ?? {};
            final fallbackUser = UserModel.fromJson(rawUser is Map<String, dynamic> ? rawUser : {
              'email': event.email,
              'name': event.email.split('@').first,
              'role': 'external',
              'userType': 'external',
            });
            _currentUser = fallbackUser;
            emit(Authenticated(fallbackUser));
          }
        } else {
          emit(AuthError(result['message'] ?? 'External login failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<Verify2FARequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.verify2FA(event.email, event.otp);
        if (result['success'] == true) {
          try {
            final user = await _userService.getMe();
            _currentUser = user;
            emit(Authenticated(user));
          } catch (_) {
            final rawUser = result['data']?['user'] ?? {};
            final fallbackUser = UserModel.fromJson(rawUser is Map<String, dynamic> ? rawUser : {
              'email': event.email,
              'name': event.email.split('@').first,
              'role': 'admin',
            });
            _currentUser = fallbackUser;
            emit(Authenticated(fallbackUser));
          }
        } else {
          emit(AuthError(result['message'] ?? '2FA verification failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterExternalRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.registerExternal(event.name, event.email);
        if (result['success'] == true) {
          emit(const AuthPasswordResetSuccess('Registration successful. OTP sent for external login.'));
        } else {
          emit(AuthError(result['message'] ?? 'External registration failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.registerStudent(
          name: event.name,
          email: event.email,
          password: event.password,
          program: event.program,
          rollNo: event.rollNo,
          branch: event.branch,
          year: event.year,
        );

        if (result['success'] == true) {
          // If token returned (e.g. dev mode or direct register login)
          if (result['data']?['token'] != null) {
            try {
              final user = await _userService.getMe();
              _currentUser = user;
              emit(Authenticated(user));
              return;
            } catch (_) {}
          }
          emit(RegisterSuccess(result['data']?['message'] ?? 'Registration successful! Please login.'));
        } else {
          emit(AuthError(result['message'] ?? 'Registration failed'));
        }
      } catch (e) {
        emit(AuthError('An error occurred during registration: $e'));
      }
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.forgotPassword(event.email);
        if (result['success'] == true) {
          emit(AuthForgotPasswordOtpSent(event.email, result['message'] ?? 'Password reset link/code sent to your email'));
        } else {
          emit(AuthError(result['message'] ?? 'Failed to process request'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.resetPassword(event.token, event.newPassword);
        if (result['success'] == true) {
          emit(AuthPasswordResetSuccess(result['message'] ?? 'Password reset successfully'));
        } else {
          emit(AuthError(result['message'] ?? 'Failed to reset password'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ChangePasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.changePassword(event.currentPassword, event.newPassword);
        if (result['success'] == true) {
          if (_currentUser != null) {
            emit(Authenticated(_currentUser!));
          } else {
            emit(Unauthenticated());
          }
        } else {
          emit(AuthError(result['message'] ?? 'Failed to change password'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      if (_currentUser == null) return;
      try {
        final updatedUser = await _userService.updateProfile(
          role: _currentUser!.role,
          id: _currentUser!.id,
          data: event.data,
        );
        _currentUser = updatedUser;
        emit(Authenticated(updatedUser));
      } catch (e) {
        emit(AuthError('Failed to update profile: $e'));
        if (_currentUser != null) emit(Authenticated(_currentUser!));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await _authService.logout();
      _currentUser = null;
      emit(Unauthenticated());
    });
  }
}
