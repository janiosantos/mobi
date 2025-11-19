import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    sendTimeout: ApiConstants.sendTimeout,
  ));
  getIt.registerSingleton<Dio>(dio);

  // API Service
  final apiService = ApiService(dio);
  getIt.registerSingleton<ApiService>(apiService);

  // Auth Service
  final authService = AuthService(apiService, sharedPreferences, dio);
  getIt.registerSingleton<AuthService>(authService);

  // Location Service
  final locationService = LocationService();
  getIt.registerSingleton<LocationService>(locationService);

  // Notification Service
  final notificationService = NotificationService();
  getIt.registerSingleton<NotificationService>(notificationService);

  // Theme Service
  final themeService = ThemeService(sharedPreferences);
  getIt.registerSingleton<ThemeService>(themeService);

  // Repositories
  final authRepository = AuthRepository(authService);
  getIt.registerSingleton<AuthRepository>(authRepository);

  final rideRepository = RideRepository(apiService);
  getIt.registerSingleton<RideRepository>(rideRepository);

  final paymentRepository = PaymentRepository(apiService);
  getIt.registerSingleton<PaymentRepository>(paymentRepository);
}
