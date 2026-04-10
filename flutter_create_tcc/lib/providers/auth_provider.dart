// AuthProvider: Gerencia o estado de autenticação e dados do usuário (login, logout, registro, auto-login, e CRUD de informações)
// Utiliza ChangeNotifier para notificar a interface de usuário (UI) sobre as mudanças de estado
// Armazena token e dados do usuário localmente (SharedPreferences) para persistência

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../services/user_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthServices _authService = AuthServices();
  final UserServices _userService = UserServices();
  // Dados de estado da aplicação (usuário, token de autenticação e indicador de carregamento)
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  // Getters públicos para acessar o estado
  UserModel? get user => _user;
  String? get token => _token;
  // Lógica para verificar se o usuário está autenticado
  bool get isAuthenticated => _user != null && _token != null;
  bool get isLoading => _isLoading;

  // LOGIN
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    _isLoading = true;
    notifyListeners(); // 1. Inicia carregamento e notifica UI

    final result = await _authService.login(loginId, password);

    _isLoading = false;

    if (result['success'] == true) {
      final responseData = result['data'] as Map<String, dynamic>?;

      final data =
          (responseData?['data'] ?? responseData) as Map<String, dynamic>?;

      if (data != null) {
        _token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (userData != null && _token != null) {
          _user = UserModel.fromJson(userData);

          // 2. Persiste o token e os dados do usuário no armazenamento local
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners(); // 3. Notifica a UI sobre a autenticação bem-sucedida
          return {
            'success': true,
            'data': {'user': userData, 'token': _token},
          };
        } else {
          // Limpa estado se os dados de usuário estiverem incompletos, mesmo com 'success' do serviço
          _user = null;
          _token = null;
          return {'success': false, 'error': 'Dados de usuário incompletos.'};
        }
      }
    }

    notifyListeners(); // Notifica UI para encerrar o estado de carregamento em caso de falha
    return result;
  }

  // REGISTER
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    notifyListeners(); // 1. Inicia carregamento e notifica UI

    final result = await _authService.register(email, password, phone);

    _isLoading = false;
    notifyListeners(); // 2. Finaliza carregamento e notifica UI

    return result; // Retorna o resultado da operação (sucesso/erro)
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Remove o token e os dados do usuário do armazenamento local
    await prefs.remove('token');
    await prefs.remove('user');

    // 2. Limpa o estado local.
    _token = null;
    _user = null;

    notifyListeners(); // 3. Notifica a UI sobre o logout
  }

  // AUTO LOGIN
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final storedToken = prefs.getString('token');
    final storedUser = prefs.getString('user');

    // 1. Verifica se os dados necessários para o auto-login existem localmente
    if (storedToken == null || storedUser == null) {
      return false;
    }

    try {
      final userData = jsonDecode(
        storedUser,
      ); // 2. Decodifica os dados armazenados.
      _token = storedToken;
      _user = UserModel.fromJson(userData); // 3. Reconstrói o objeto UserModel
      notifyListeners();
      return true;
    } catch (e) {
      // Em caso de erro na decodificação (dados corrompidos), efetua logout forçado
      await logout();
      return false;
    }
  }

  // UPDATE USER DATA - Permite atualizar nome e CPF do usuário (Requer autenticação)
  Future<Map<String, dynamic>> updateUserData({
    String? name,
    String? cpf,
  }) async {
    // 1. Garante que há um usuário autenticado antes de prosseguir
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.updateUserData(
        token: _token!,
        name: name,
        cpf: (cpf != null && cpf.isNotEmpty) ? cpf : null,
      );

      _isLoading = false;

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>?;
        final data =
            (responseData?['data'] ?? responseData) as Map<String, dynamic>?;

        if (data != null && data['user'] != null) {
          final updatedUser = data['user'] as Map<String, dynamic>;
          _user = UserModel.fromJson(
            updatedUser,
          ); // 3. Atualiza o estado local do usuário com os novos dados

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'user',
            jsonEncode(_user!.toJson()),
          ); // 4. Persiste a atualização localmente.

          notifyListeners();
          return {
            'success': true,
            'data': {'user': updatedUser},
          };
        } else {
          return {'success': false, 'error': 'Resposta do servidor inválida.'};
        }
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Erro desconhecido.',
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': 'Erro: $e'};
    }
  }

  // UPDATE ACCESS INFO - Mudança: Removido userId (usa token do backend)
  Future<Map<String, dynamic>> updateAccessInfo({
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    // Lógica similar a updateUserData: validação, início/fim de carregamento, chamada ao serviço e atualização do estado
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.updateAccessInfo(
        token: _token!,
        phone: phone,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;

      if (result['success'] == true) {
        // O backend pode retornar os dados atualizados do usuário (incluindo o telefone novo) ou apenas uma mensagem de sucesso
        final data = result['data'] as Map<String, dynamic>;

        // Verifica se a resposta contém os campos esperados para atualizar o modelo local
        if (data.containsKey('id') || data.containsKey('email')) {
          // Atualiza o modelo local com o novo JSON recebido do Go
          _user = UserModel.fromJson(data);

          // Persiste a atualização localmente (SharedPreferences)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {
            'success': true,
            'data': {'user': data},
          };
        } else {
          return {'success': false, 'error': 'Formato de resposta inesperado.'};
        }
      } else {
        notifyListeners();
        return result;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': 'Erro: $e'};
    }
  }

  // FORGOT PASSWORD - solicita envio do OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.forgotPassword(email);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // RESET PASSWORD - envia nova senha junto com OTP para redefinir a senha do usuário
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.resetPassword(email, otp, newPassword);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // RESEND OTP - reenvia código OTP para o email do usuário
  Future<Map<String, dynamic>> resendOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.forgotPassword(email);

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
