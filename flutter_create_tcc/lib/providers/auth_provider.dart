import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/auth_services.dart';
import '../services/user_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthServices _authService = AuthServices();
  final UserServices _userService = UserServices();
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

      final data =
          (responseData?['data'] ?? responseData) as Map<String, dynamic>?;

      if (data != null) {
        _token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (userData != null && _token != null) {
          _user = UserModel.fromJson(userData);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          await prefs.setString('user', jsonEncode(_user!.toJson()));

          notifyListeners();
          return {
            'success': true,
            'data': {'user': userData, 'token': _token},
          };
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

  // UPDATE USER DATA - Mudança: Removido userId (usa token do backend)
  Future<Map<String, dynamic>> updateUserData({
    String? name,
    String? cpf,
  }) async {
    if (_token == null || _user == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.updateUserData(
        token: _token!,
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

  // UPDATE ACCESS INFO - Mudança: Removido userId (usa token do backend)
  Future<Map<String, dynamic>> updateAccessInfo({
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
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

extension UserModelCopyWith on UserModel {
  UserModel copyWith({List<AddressModel>? addresses}) {
    final Map<String, dynamic> data =
        jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>;

    if (addresses != null) {
      data['addresses'] = addresses
          .map((a) => a.toJson())
          .toList(growable: false);
    }

    return UserModel.fromJson(data);
  }
}
