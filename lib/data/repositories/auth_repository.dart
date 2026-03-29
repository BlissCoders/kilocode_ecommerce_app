import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  AuthRepository(this._prefs);

  // Mock authentication - In production, use Firebase Auth
  Future<UserModel?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation - accept any valid email format with password length >= 6
    if (_isValidEmail(email) && password.length >= AppConstants.minPasswordLength) {
      // Check if user exists in storage
      final userJson = _prefs.getString('user_$email');
      if (userJson != null) {
        final user = UserModel.fromJson(jsonDecode(userJson));
        await _prefs.setBool(AppConstants.isLoggedInKey, true);
        await _prefs.setString(AppConstants.userKey, userJson);
        return user;
      }
      
      // Create new user session (for demo purposes)
      final user = UserModel(
        id: _uuid.v4(),
        email: email,
        name: email.split('@').first,
        createdAt: DateTime.now(),
      );
      
      await _prefs.setBool(AppConstants.isLoggedInKey, true);
      await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
      return user;
    }
    
    throw AuthException('Invalid email or password');
  }

  Future<UserModel?> register(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Validate inputs
    if (!_isValidEmail(email)) {
      throw AuthException('Please enter a valid email address');
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      throw AuthException('Password must be at least ${AppConstants.minPasswordLength} characters');
    }
    
    if (name.length < AppConstants.minNameLength) {
      throw AuthException('Name must be at least ${AppConstants.minNameLength} characters');
    }
    
    // Check if user already exists
    final existingUser = _prefs.getString('user_$email');
    if (existingUser != null) {
      throw AuthException('An account with this email already exists');
    }
    
    // Create new user
    final user = UserModel(
      id: _uuid.v4(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    
    // Save user data
    await _prefs.setString('user_$email', jsonEncode(user.toJson()));
    await _prefs.setBool(AppConstants.isLoggedInKey, true);
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    
    return user;
  }

  Future<void> logout() async {
    await _prefs.setBool(AppConstants.isLoggedInKey, false);
    await _prefs.remove(AppConstants.userKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final isLoggedIn = _prefs.getBool(AppConstants.isLoggedInKey) ?? false;
    if (!isLoggedIn) return null;
    
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    
    return UserModel.fromJson(jsonDecode(userJson));
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<UserModel?> updateProfile(UserModel user) async {
    await _prefs.setString('user_${user.email}', jsonEncode(user.toJson()));
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    return user;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}
