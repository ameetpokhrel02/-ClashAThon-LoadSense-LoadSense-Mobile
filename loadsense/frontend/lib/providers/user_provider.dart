import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service = UserService();

  User? _profile;
  bool _isLoading = false;
  String? _error;

  User? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    String? ward,
    String? address,
    File? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        ward: ward,
        address: address,
        avatar: avatar,
      );
      notifyListeners();
      return _profile;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
