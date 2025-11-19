import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterDriverRequested>(_onRegisterDriverRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RefreshProfileRequested>(_onRefreshProfileRequested);
    on<UpdateDeviceTokenRequested>(_onUpdateDeviceTokenRequested);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.checkAuth();

      if (result['isAuthenticated'] == true) {
        emit(Authenticated(
          user: result['user'],
          token: result['token'],
        ));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.login(event.email, event.password);

      if (result['success'] == true) {
        // Verify user is a driver
        final user = result['user'] as User;
        if (user.userType != 'driver') {
          emit(const AuthError('Esta conta não é de motorista. Use o app de passageiro.'));
          return;
        }

        emit(Authenticated(
          user: user,
          token: result['token'],
        ));
      } else {
        emit(AuthError(result['message'] ?? 'Erro ao fazer login'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterDriverRequested(
    RegisterDriverRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const RegistrationLoading());

    try {
      final result = await authRepository.registerDriver({
        'name': event.name,
        'email': event.email,
        'phone': event.phone,
        'cpf': event.cpf,
        'birth_date': event.birthDate,
        'password': event.password,
        'user_type': 'driver',
      });

      if (result['success'] == true) {
        emit(const RegistrationSuccess());
      } else {
        emit(RegistrationError(result['message'] ?? 'Erro ao registrar'));
      }
    } catch (e) {
      emit(RegistrationError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const Unauthenticated());
  }

  Future<void> _onRefreshProfileRequested(
    RefreshProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentState = state as Authenticated;

    try {
      final result = await authRepository.getProfile();

      if (result['success'] == true) {
        emit(Authenticated(
          user: result['user'],
          token: currentState.token,
        ));
      }
    } catch (e) {
      // Silent fail - keep current state
    }
  }

  Future<void> _onUpdateDeviceTokenRequested(
    UpdateDeviceTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.updateDeviceToken(event.deviceToken);
    } catch (e) {
      // Silent fail
    }
  }
}
