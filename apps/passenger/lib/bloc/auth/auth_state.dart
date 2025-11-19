import 'package:equatable/equatable.dart';
import 'package:mobi_core/mobi_core.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  final String token;

  const Authenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class RegistrationLoading extends AuthState {
  const RegistrationLoading();
}

class RegistrationSuccess extends AuthState {
  final User user;
  final String token;

  const RegistrationSuccess({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class RegistrationError extends AuthState {
  final String message;

  const RegistrationError(this.message);

  @override
  List<Object?> get props => [message];
}
