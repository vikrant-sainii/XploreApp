import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

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
  List<Object?> get props => [name, rollNo, branch, year, program, email, password];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String rollNo;
  const ForgotPasswordRequested(this.rollNo);

  @override
  List<Object?> get props => [rollNo];
}

class OtpVerificationRequested extends AuthEvent {
  final String otp;
  const OtpVerificationRequested(this.otp);

  @override
  List<Object?> get props => [otp];
}

class ResetPasswordRequested extends AuthEvent {
  final String newPassword;
  const ResetPasswordRequested(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

