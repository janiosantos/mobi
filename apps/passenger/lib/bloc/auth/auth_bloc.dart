import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterPassengerRequested>(_onRegisterPassengerRequested);
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
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        final token = await authRepository.getToken();

        if (user != null && token != null) {
          emit(Authenticated(user: user, token: token));
        } else {
          emit(const Unauthenticated());
        }
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
        emit(Authenticated(
          user: result['user'],
          token: result['token'],
        ));
      } else {
        emit(AuthError(result['message'] ?? 'Erro ao fazer login'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterPassengerRequested(
    RegisterPassengerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const RegistrationLoading());

    try {
      final data = {
        'name': event.name,
        'email': event.email,
        'phone': event.phone,
        'password': event.password,
        'password_confirmation': event.password,
        'cpf': event.cpf,
        'birth_date': event.birthDate,
      };

      final result = await authRepository.registerPassenger(data);

      if (result['success'] == true) {
        emit(RegistrationSuccess(
          user: result['user'],
          token: result['token'],
        ));

        // Automatically authenticate after registration
        emit(Authenticated(
          user: result['user'],
          token: result['token'],
        ));
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
    emit(const AuthLoading());

    try {
      await authRepository.logout();
      emit(const Unauthenticated());
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onRefreshProfileRequested(
    RefreshProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    try {
      final user = await authRepository.refreshProfile();
      final token = await authRepository.getToken();

      if (user != null && token != null) {
        emit(Authenticated(user: user, token: token));
      }
    } catch (e) {
      // Keep current state if refresh fails
    }
  }

  Future<void> _onUpdateDeviceTokenRequested(
    UpdateDeviceTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Implement device token update to backend
    // This will be used for push notifications
  }
}
