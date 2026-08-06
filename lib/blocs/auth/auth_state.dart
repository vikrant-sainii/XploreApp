import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// ─── Generic ──────────────────────────────────────────────────────────────────

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Authenticated ────────────────────────────────────────────────────────────

/// Emitted after a successful login / 2FA verification.
class Authenticated extends AuthState {
  final UserModel user;

  /// Top-level role string as returned by the backend
  /// e.g. 'member' | 'club' | 'external' | 'superAdmin' | 'facultyCoordinator'
  final String role;

  const Authenticated(this.user, {required this.role});

  @override
  List<Object?> get props => [user, role];
}

class Unauthenticated extends AuthState {}

// ─── Registration ─────────────────────────────────────────────────────────────

/// Emitted after a successful student registration that requires email
/// verification (production mode). In dev mode `Authenticated` is emitted
/// instead.
class RegisterSuccess extends AuthState {
  final String message;

  const RegisterSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── 2FA ──────────────────────────────────────────────────────────────────────

/// Backend responded with `needs2FA: true` — the UI should show an OTP input.
class Needs2FA extends AuthState {
  final String email;
  final String message;

  const Needs2FA({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// ─── External user ────────────────────────────────────────────────────────────

/// An OTP has been sent to the external user's email.
class ExternalOtpSent extends AuthState {
  final String email;
  final String message;

  const ExternalOtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// ─── Forgot / Reset password ─────────────────────────────────────────────────

/// Reset link has been sent successfully.
class AuthForgotPasswordLinkSent extends AuthState {}

/// Password was successfully reset.
class AuthPasswordResetSuccess extends AuthState {}

/// Password was successfully changed (authenticated flow).
class AuthPasswordChangeSuccess extends AuthState {}

// ─── Email verification ───────────────────────────────────────────────────────

class EmailVerificationSuccess extends AuthState {}
