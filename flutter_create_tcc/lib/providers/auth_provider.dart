import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isLoading => _isLoading;

  // LOGIN
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(loginId, password);

    _isLoading = false;

    if (result['success'] == true) {

      final responseData = result['data'] as Map<String, dynamic>?;

      final data = (responseData?['data'] ?? responseData) as Map<String, dynamic>?;

      if (data != null) {
        _token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (userData != null && _token != null) {
          _user = UserModel.fromJson(userData);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {'success': true, 'data': {'user': userData, 'token': _token}};
        } else {
          _user = null;
          _token = null;
          return {'success': false, 'error': 'Dados de usuário incompletos.'};
        }
      }
    }

    notifyListeners();
    return result;
  }

  // REGISTER
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(email, password, phone);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    _token = null;
    _user = null;

    notifyListeners();
  }

  // AUTO LOGIN
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final storedToken = prefs.getString('token');
    final storedUser = prefs.getString('user');

    if (storedToken == null || storedUser == null) {
      return false;
    }

    try {
      final userData = jsonDecode(storedUser);
      _token = storedToken;
      _user = UserModel.fromJson(userData);
      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }
}
