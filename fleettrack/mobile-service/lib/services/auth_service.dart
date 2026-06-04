import 'package:shared_preferences/shared_preferences.dart';
import 'base_service.dart';
import '../core/api_config.dart';

class AuthService extends BaseService {
  Future<bool> login(String email, String password) async {
    try {
      final response = await authDio.post(
        ApiConfig.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', user.toString()); // Simple storage for now
        return true;
      }
      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await authDio.post(ApiConfig.logout);
    } catch (e) {
      print("LOGOUT ERROR: $e");
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    }
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await authDio.get(ApiConfig.me);
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }
}
