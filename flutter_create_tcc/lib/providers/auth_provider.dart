// AuthProvider: Gerencia o estado de autenticação e dados do usuário (login, logout, registro, auto-login, e CRUD de informações/endereços)
// Utiliza ChangeNotifier para notificar a interface de usuário (UI) sobre as mudanças de estado
// Armazena token e dados do usuário localmente (SharedPreferences) para persistência

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
//import '../models/address_model.dart';
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

  // UPDATE USER DATA - Mudança: Removido userId (usa token do backend)
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
        token:
            _token!, // 2. Envia o token para o serviço para identificar o usuário no backend
        name: name,
        cpf: cpf,
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
        final responseData = result['data'] as Map<String, dynamic>?;
        final data =
            (responseData?['data'] ?? responseData) as Map<String, dynamic>?;

        if (data != null && data['user'] != null) {
          final updatedUser = data['user'] as Map<String, dynamic>;
          _user = UserModel.fromJson(updatedUser);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

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

  /*
  // GET ADDRESSES - Novo método: Lista endereços e atualiza _user.addresses
  Future<Map<String, dynamic>> getAddresses() async {
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.getAddresses(token: _token!);

      _isLoading = false;

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>?;
        if (responseData != null && responseData['addresses'] != null) {
          final addresses = responseData['addresses'] as List<dynamic>;
          // 1. Atualiza a lista de endereços no objeto _user local, mantendo as outras propriedades
          _user = _user!.copyWith(
            addresses: addresses.map((e) => AddressModel.fromJson(e)).toList(),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'user',
            jsonEncode(_user!.toJson()),
          ); // 2. Persiste o novo estado do usuário

          notifyListeners();
          return {
            'success': true,
            'data': {'addresses': addresses},
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

  // ADD ADDRESS - Novo método: Adiciona endereço e atualiza _user.addresses
  Future<Map<String, dynamic>> addAddress({
    required String street,
    required String number,
    required String city,
    required String state,
    required String zip,
    required String neighborhood,
    String? complement,
  }) async {
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.addAddress(
        token: _token!,
        street: street,
        number: number,
        city: city,
        state: state,
        zip: zip,
        neighborhood: neighborhood,
        complement: complement,
      );

      _isLoading = false;

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>?;
        if (responseData != null && responseData['addresses'] != null) {
          final addresses = responseData['addresses'] as List<dynamic>;
          // 1. O backend retorna a lista completa de endereços após a adição; atualiza o estado local
          _user = _user!.copyWith(
            addresses: addresses.map((e) => AddressModel.fromJson(e)).toList(),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {
            'success': true,
            'data': {'addresses': addresses},
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

  // SET DEFAULT ADDRESS
  Future<Map<String, dynamic>> setDefaultAddress({
    required String addressId,
  }) async {
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.setDefaultAddress(
        token: _token!,
        addressId: addressId,
      );

      _isLoading = false;

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>?;

        if (responseData != null && responseData['user'] != null) {
          final userData = responseData['user'] as Map<String, dynamic>;

          // 1. Atualiza o defaultAddressId e a lista de endereços (se fornecida) no estado local
          _user = _user!.copyWith(
            defaultAddressId: userData['defaultAddressId'] as String?,
            addresses: (userData['addresses'] as List<dynamic>?)
                ?.map((e) => AddressModel.fromJson(e))
                .toList(),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {
            'success': true,
            'data': {'user': userData},
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

  // UPDATE ADDRESS - Novo método: Atualiza endereço e sincroniza _user.addresses
  Future<Map<String, dynamic>> updateAddress({
    required String addressId,
    String? street,
    String? number,
    String? city,
    String? state,
    String? zip,
    String? neighborhood,
    String? complement,
  }) async {
    // Lógica de atualização de endereço: validação, chamada ao serviço e sincronização da lista de endereços do usuário
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.updateAddress(
        token: _token!,
        addressId: addressId,
        street: street,
        number: number,
        city: city,
        state: state,
        zip: zip,
        neighborhood: neighborhood,
        complement: complement,
      );

      _isLoading = false;

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>?;
        if (responseData != null && responseData['addresses'] != null) {
          final addresses = responseData['addresses'] as List<dynamic>;
          _user = _user!.copyWith(
            addresses: addresses.map((e) => AddressModel.fromJson(e)).toList(),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {
            'success': true,
            'data': {'addresses': addresses},
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

  // DELETE ADDRESS - Novo método: Deleta endereço e atualiza _user.addresses
  Future<Map<String, dynamic>> deleteAddress({
    required String addressId,
  }) async {
    // Lógica de exclusão de endereço: validação, chamada ao serviço e sincronização da lista de endereços do usuário
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.deleteAddress(
        token: _token!,
        addressId: addressId,
      );

      _isLoading = false;

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>?;
        if (responseData != null && responseData['addresses'] != null) {
          final addresses = responseData['addresses'] as List<dynamic>;
          // Atualiza a lista de endereços no objeto _user com a lista retornada pelo servidor
          _user = _user!.copyWith(
            addresses: addresses.map((e) => AddressModel.fromJson(e)).toList(),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {
            'success': true,
            'data': {'addresses': addresses},
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
}

// Extensão para adicionar o método copyWith no UserModel, facilitando a atualização de listas imutáveis
extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    List<AddressModel>? addresses,
    String? defaultAddressId,
  }) {
    // 1. Cria uma cópia profunda (Deep Copy) do objeto atual através de serialização/desserialização JSON.
    final Map<String, dynamic> data =
        jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>;

    // 2. Aplica as alterações se o novo valor for fornecido.
    if (addresses != null) {
      data['addresses'] = addresses
          .map((a) => a.toJson())
          .toList(growable: false);
    }
    if (defaultAddressId != null) {
      data['defaultAddressId'] = defaultAddressId;
    }

    return UserModel.fromJson(data); // 3. Cria um novo objeto com os dados atualizados.
  }
*/
}
