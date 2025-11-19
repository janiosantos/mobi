import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterDriverRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String cpf;
  final String birthDate;
  final String password;

  const RegisterDriverRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.birthDate,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, cpf, birthDate, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RefreshProfileRequested extends AuthEvent {
  const RefreshProfileRequested();
}

class UpdateDeviceTokenRequested extends AuthEvent {
  final String deviceToken;

  const UpdateDeviceTokenRequested(this.deviceToken);

  @override
  List<Object?> get props => [deviceToken];
}
