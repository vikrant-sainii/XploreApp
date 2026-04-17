import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userEmail;
  const Authenticated(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}

class Unauthenticated extends AuthState {}

// States for forgot password flow
class AuthForgotPasswordOtpSent extends AuthState {}
class AuthForgotPasswordVerified extends AuthState {}
class AuthPasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
