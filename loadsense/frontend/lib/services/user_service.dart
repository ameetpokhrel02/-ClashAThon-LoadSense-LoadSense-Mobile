import 'dart:io';
import '../core/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  Future<User> getProfile() async {
    final data = await ApiService.get(ApiConstants.profile);
    final userData = data['user'] ?? (data['data'] is Map ? data['data']['user'] : data);
    return User.fromJson(userData ?? data);
  }

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    String? ward,
    String? address,
    File? avatar,
  }) async {
    dynamic data;

    if (avatar != null) {
      // Use multipart form upload when an image is being changed
      final fields = <String, String>{
        'firstName': firstName,
        'lastName': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (ward != null && ward.isNotEmpty) 'ward': ward,
        if (address != null && address.isNotEmpty) 'address': address,
      };
      data = await ApiService.multipartPatch(
        ApiConstants.profile,
        fields,
        imageFile: avatar,
      );
    } else {
      // No image — use regular JSON PATCH (faster, more reliable)
      final body = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (ward != null && ward.isNotEmpty) 'ward': ward,
        if (address != null && address.isNotEmpty) 'address': address,
      };
      data = await ApiService.patch(ApiConstants.profile, body);
    }

    // Support multiple response shapes from the backend
    final userData = data['user'] ??
        data['data']?['user'] ??
        data['data'] ??
        data;

    if (userData is! Map<String, dynamic>) {
      throw ApiException('Unexpected response format from server');
    }
    return User.fromJson(userData);
  }
}
