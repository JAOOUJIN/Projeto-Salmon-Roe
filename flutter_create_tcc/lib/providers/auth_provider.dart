// AuthProvider: Gerencia o estado de autenticação e dados do usuário (login, logout, registro, auto-login, e CRUD de informações)
// Utiliza ChangeNotifier para notificar a interface de usuário (UI) sobre as mudanças de estado
// Armazena token e dados do usuário localmente (SharedPreferences) para persistência

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../services/user_services.dart';
import '../services/notification_services.dart';
import '../services/websocket_service.dart';
import '../providers/notification_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthServices _authService = AuthServices();
  final UserServices _userService = UserServices();
  final NotificationServices _notificationService = NotificationServices();
  final WebSocketService _webSocketService = WebSocketService();

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

  String? _lastConfirmedSaleId;
  String? get lastConfirmedSaleId => _lastConfirmedSaleId;

  // Método para resetar após a animação (importante!)
  void clearLastConfirmedSale() {
    _lastConfirmedSaleId = null;
  }

  // LOGIN
  Future<Map<String, dynamic>> login(
    String loginId,
    String password,
    NotificationProvider notificationProvider,
    OrdersProvider ordersProvider,
  ) async {
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

          await _notificationService.inicializarNotificacoes(_token);

          // Configura o ouvinte de notificações para atualizar a UI em tempo real quando uma nova notificação chegar
          notificationProvider.configurarOuvinte(ordersProvider, _token!);
          notificationProvider.verificarMensagemInicial(
            ordersProvider,
            _token!,
          );

          _webSocketService.conectar(_token!, (data) {
            print("Mensagem em tempo real recebida: $data");

            if (data['type'] == 'payment_confirmed') {
              // Guarda o ID da venda que foi paga para exibir a animação de confirmação na tela de PIX
              _lastConfirmedSaleId = data['saleId']?.toString();
              print(
                "O pagamento do pedido $_lastConfirmedSaleId foi confirmado!",
              );

              // Notifica os ouvintes (incluindo a tela de PIX)
              notifyListeners();
            }

            if (data['type'] == 'order_status') {
              print(
                "AUTH_PROVIDER: Status de pedido recebido, notificando ouvintes...",
              );

              ordersProvider.fetchOrders(_token!);
              ordersProvider.fetchLastOrderStatus(_token!);

              notifyListeners();
            }
          });

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

  // LOGOUT - Agora recebe os providers que precisam ser limpos
  Future<void> logout(
    OrdersProvider ordersProvider,
    NotificationProvider notificationProvider,
    CartProvider cartProvider,
    AddressProvider addressProvider,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Remove os dados de autenticação do disco
    await prefs.remove('token');
    await prefs.remove('user');

    // 2. Limpa o estado local do Auth
    _token = null;
    _user = null;
    _webSocketService.desconectar();

    // 3. LIMPA OS DADOS DOS OUTROS PROVIDERS
    ordersProvider.clearOrders();
    notificationProvider.clearNotifications();
    cartProvider.clearCart();
    addressProvider.clear();

    notifyListeners();
  }

  // AUTO LOGIN
  Future<bool> tryAutoLogin(
    NotificationProvider notificationProvider,
    OrdersProvider ordersProvider,
    CartProvider cartProvider,
    AddressProvider addressProvider,
  ) async {
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

      await _notificationService.inicializarNotificacoes(_token);

      notificationProvider.configurarOuvinte(ordersProvider, _token!);
      notificationProvider.verificarMensagemInicial(ordersProvider, _token!);

      _webSocketService.conectar(_token!, (data) {
        print("Mensagem em tempo real recebida: $data");

        if (data['type'] == 'payment_confirmed') {
          // Guarda o ID da venda que foi paga para exibir a animação de confirmação na tela de PIX
          _lastConfirmedSaleId = data['saleId']?.toString();
          print("O pagamento do pedido $_lastConfirmedSaleId foi confirmado!");

          // Notifica os ouvintes (incluindo a tela de PIX)
          notifyListeners();
        }

        if (data['type'] == 'order_status') {
          print(
            "AUTH_PROVIDER: Status de pedido recebido, notificando ouvintes...",
          );
          ordersProvider.fetchOrders(_token!);
          ordersProvider.fetchLastOrderStatus(_token!);

          notifyListeners();
        }
      });

      notifyListeners();
      return true;
    } catch (e) {
      // Em caso de erro na decodificação (dados corrompidos), efetua logout forçado
      await logout(
        ordersProvider,
        notificationProvider,
        cartProvider,
        addressProvider,
      );
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
        // O Go retorna os dados diretamente (name, cpf, updatedAt)
        final data = result['data'] as Map<String, dynamic>?;

        if (data != null) {
          // 2. ATUALIZAÇÃO LOCAL: Mantemos os dados fixos (id, email, phone)
          // e trocamos apenas o que foi alterado no banco
          _user = _user!.copyWith(
            name: data['name'] ?? _user!.name,
            cpf: data['cpf'] ?? _user!.cpf,
          );

          // 3. PERSISTÊNCIA: Atualiza o JSON no disco para o Auto-Login ler os dados novos
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          // 4. UI: Notifica todos os widgets sobre a mudança
          notifyListeners();

          return {
            'success': true,
            'data': {'user': _user!.toJson()},
          };
        } else {
          return {'success': false, 'error': 'Dados de resposta vazios.'};
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
