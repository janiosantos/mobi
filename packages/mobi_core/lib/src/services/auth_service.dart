import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthService {
  final ApiService _apiService;
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthService(this._apiService, this._prefs, this._dio) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers[ApiConstants.authorization] =
                '${ApiConstants.bearer} $token';
          }
          options.headers[ApiConstants.accept] = ApiConstants.applicationJson;
          options.headers[ApiConstants.contentType] =
              ApiConstants.applicationJson;
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await logout();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login({
        'email': email,
        'password': password,
      });

      if (response.response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await saveToken(token);
        await saveUser(user);

        return {'success': true, 'user': user, 'token': token};
      }

      return {'success': false, 'message': 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerPassenger(
      Map<String, dynamic> data) async {
    try {
      final response = await _apiService.registerPassenger(data);

      if (response.response.statusCode == 201) {
        final responseData = response.data['data'];
        final token = responseData['token'];
        final user = User.fromJson(responseData['user']);

        await saveToken(token);
        await saveUser(user);

        return {'success': true, 'user': user, 'token': token};
      }

      return {'success': false, 'message': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.registerDriver(data);

      if (response.response.statusCode == 201) {
        final responseData = response.data['data'];
        final token = responseData['token'];
        final user = User.fromJson(responseData['user']);

        await saveToken(token);
        await saveUser(user);

        return {'success': true, 'user': user, 'token': token};
      }

      return {'success': false, 'message': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await clearAuthData();
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.storageKeyToken);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.storageKeyToken, token);
  }

  Future<User?> getUser() async {
    final userJson = _prefs.getString(AppConstants.storageKeyUser);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString(
      AppConstants.storageKeyUser,
      json.encode(user.toJson()),
    );
  }

  Future<void> clearAuthData() async {
    await _prefs.remove(AppConstants.storageKeyToken);
    await _prefs.remove(AppConstants.storageKeyUser);
  }

  Future<User?> refreshProfile() async {
    try {
      final response = await _apiService.getProfile();
      if (response.response.statusCode == 200) {
        final user = User.fromJson(response.data['data']);
        await saveUser(user);
        return user;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
}
