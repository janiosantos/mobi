import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<Map<String, dynamic>> registerPassenger(
      Map<String, dynamic> data) async {
    return await _authService.registerPassenger(data);
  }

  Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> data) async {
    return await _authService.registerDriver(data);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  Future<User?> getCurrentUser() async {
    return await _authService.getUser();
  }

  Future<User?> refreshProfile() async {
    return await _authService.refreshProfile();
  }
}
