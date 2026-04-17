import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      // Mimic network delay
      await Future.delayed(const Duration(seconds: 1));
      // Bypassing credential check for user testing
      emit(Authenticated(event.email.isEmpty ? "Testing User" : event.email));
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(Unauthenticated());
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthForgotPasswordOtpSent());
    });

    on<OtpVerificationRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 1));
      if (event.otp.length == 4) { // mock verification limit
        emit(AuthForgotPasswordVerified());
      } else {
        emit(const AuthError("Invalid OTP"));
      }
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthPasswordResetSuccess());
    });
  }
}
