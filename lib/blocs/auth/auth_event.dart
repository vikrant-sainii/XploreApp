import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ─── Student login ──────────────────────────────────────────────────────────

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// ─── Admin login ────────────────────────────────────────────────────────────

class AdminLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AdminLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// ─── Student registration ───────────────────────────────────────────────────

class RegisterRequested extends AuthEvent {
  final String name;
  final String rollNo;
  final String branch;
  final String year;
  final String program;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.rollNo,
    required this.branch,
    required this.year,
    required this.program,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props =>
      [name, rollNo, branch, year, program, email, password];
}

// ─── External user (OTP-based) ───────────────────────────────────────────────

class RegisterExternalRequested extends AuthEvent {
  final String name;
  final String email;

  const RegisterExternalRequested({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}

class LoginExternalRequested extends AuthEvent {
  final String email;
  final String otp;

  const LoginExternalRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

// ─── 2FA ─────────────────────────────────────────────────────────────────────

class Verify2FARequested extends AuthEvent {
  final String email;
  final String otp;

  const Verify2FARequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

// ─── Logout ──────────────────────────────────────────────────────────────────

class LogoutRequested extends AuthEvent {}

// ─── Forgot / Reset password ──────────────────────────────────────────────────

class ForgotPasswordRequested extends AuthEvent {
  /// The user's registered email address.
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  /// Raw token from the reset-password email link.
  final String token;
  final String newPassword;

  const ResetPasswordRequested({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}

// ─── Change password (authenticated) ─────────────────────────────────────────

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// ─── Email verification ───────────────────────────────────────────────────────

class VerifyEmailRequested extends AuthEvent {
  final String token;

  const VerifyEmailRequested(this.token);

  @override
  List<Object?> get props => [token];
}

// ─── Check Session ───────────────────────────────────────────────────────────

class CheckSession extends AuthEvent {}
