import '../core/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final data = await ApiService.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      ApiConstants.register,
      {'firstName': firstName, 'lastName': lastName, 'email': email, 'password': password},
      auth: false,
    );
    return AuthResponse.fromJson(data);
  }

  Future<void> forgotPassword(String email) async {
    await ApiService.post(ApiConstants.forgotPassword, {'email': email}, auth: false);
  }

  Future<void> verifyOtp(String email, String otp) async {
    await ApiService.post(ApiConstants.verifyOtp, {'email': email, 'otp': otp}, auth: false);
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await ApiService.post(
      ApiConstants.resetPassword,
      {'email': email, 'otp': otp, 'newPassword': newPassword},
      auth: false,
    );
  }

  Future<User> getMe() async {
    final data = await ApiService.get(ApiConstants.me);
    return User.fromJson(data['user'] ?? data);
  }
}
