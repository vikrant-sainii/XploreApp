import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool isAdmin;

  const LoginRequested(this.email, this.password, {this.isAdmin = false});

  @override
  List<Object?> get props => [email, password, isAdmin];
}

class ExternalLoginRequested extends AuthEvent {
  final String email;
  final String otp;

  const ExternalLoginRequested(this.email, this.otp);

  @override
  List<Object?> get props => [email, otp];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String? rollNo;
  final String? branch;
  final dynamic year;
  final String program;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    this.rollNo,
    this.branch,
    this.year,
    required this.program,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, rollNo, branch, year, program, email, password];
}

class RegisterStudentRequested extends RegisterRequested {
  const RegisterStudentRequested({
    required super.name,
    super.rollNo,
    super.branch,
    super.year,
    required super.program,
    required super.email,
    required super.password,
  });
}

class RegisterExternalRequested extends AuthEvent {
  final String name;
  final String email;

  const RegisterExternalRequested(this.name, this.email);

  @override
  List<Object?> get props => [name, email];
}

class Verify2FARequested extends AuthEvent {
  final String email;
  final String otp;

  const Verify2FARequested(this.email, this.otp);

  @override
  List<Object?> get props => [email, otp];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested(this.token, this.newPassword);

  @override
  List<Object?> get props => [token, newPassword];
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested(this.currentPassword, this.newPassword);

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class UpdateProfileRequested extends AuthEvent {
  final Map<String, dynamic> data;

  const UpdateProfileRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class LogoutRequested extends AuthEvent {}
