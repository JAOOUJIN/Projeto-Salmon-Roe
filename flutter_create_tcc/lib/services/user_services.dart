// UserServices: Esta classe gerencia todas as operações de comunicação de rede (API)
// relacionadas ao perfil do usuário (atualizações de dados, senhas, e endereços)
// Todas as operações requerem o token de autenticação para identificar o usuário

import 'package:dio/dio.dart';
import '../utils/config.dart';

// Serviços de usuário
class UserServices {
  final Dio dio = Dio();
  final String baseUrl =
      "${Config.baseUrl}/user"; // Endereço base para as rotas de usuário

  // UPDATE USER DATA (nome, CPF)
  Future<Map<String, dynamic>> updateUserData({
    required String token,
    String? name,
    String? cpf,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-info',
        data: {
          // Inclui o campo 'name' no corpo da requisição APENAS se o valor não for nulo (if condicional)
          if (name != null) 'name': name, if (cpf != null) 'cpf': cpf,
        },
        // Autentica a requisição usando o token no cabeçalho
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros da API e retorna a mensagem de erro
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }

  // UPDATE ACCESS INFO (telefone, senha) - Removido userId da URL
  Future<Map<String, dynamic>> updateAccessInfo({
    required String token,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-access',
        data: {
          // Inclui os campos no corpo da requisição APENAS se o valor não for nulo
          if (phone != null) 'phone': phone,
          if (currentPassword != null) 'currentPassword': currentPassword,
          if (newPassword != null) 'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }

  // GET ADDRESSES (Listar endereços)
  Future<Map<String, dynamic>> getAddresses({required String token}) async {
    try {
      // Requisição GET para buscar todos os endereços vinculados ao usuário do token
      final response = await dio.get(
        '$baseUrl/', // URL para listar endereços
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }

  // ADD ADDRESS (Adicionar novo endereço)
  Future<Map<String, dynamic>> addAddress({
    required String token,
    required String street,
    required String number,
    required String city,
    required String state,
    required String zip,
    required String neighborhood,
    String? complement,
  }) async {
    try {
      // Requisição POST para criar um novo endereço
      final response = await dio.post(
        '$baseUrl/address',
        data: {
          // Todos os campos obrigatórios são enviados
          'street': street,
          'number': number,
          'city': city,
          'state': state,
          'zip': zip,
          'neighborhood': neighborhood,
          'complement': complement,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }

  /// SET DEFAULT ADDRESS (Definir endereço padrão)
  Future<Map<String, dynamic>> setDefaultAddress({
    required String token,
    required String addressId,
  }) async {
    try {
      // Requisição PUT que envia o ID do endereço a ser definido como padrão na URL
      final response = await dio.put(
        '$baseUrl/set-default-address/$addressId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }

  // UPDATE ADDRESS (Atualizar endereço)
  Future<Map<String, dynamic>> updateAddress({
    required String token,
    required String addressId,
    String? street,
    String? number,
    String? city,
    String? state,
    String? zip,
    String? neighborhood,
    String? complement,
  }) async {
    try {
      // Requisição PUT para atualizar. O ID do endereço é passado na URL
      final response = await dio.put(
        '$baseUrl/address/$addressId',
        data: {
          // O uso de 'if' garante que apenas os campos que sofreram alteração (não nulos) sejam enviados
          if (street != null) 'street': street,
          if (number != null) 'number': number,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (zip != null) 'zip': zip,
          if (neighborhood != null) 'neighborhood': neighborhood,
          if (complement != null) 'complement': complement,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros.
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }

  // DELETE ADDRESS (Excluir endereço)
  Future<Map<String, dynamic>> deleteAddress({
    required String token,
    required String addressId,
  }) async {
    try {
      // Requisição DELETE que usa o ID do endereço na URL para excluir o recurso
      final response = await dio.delete(
        '$baseUrl/address/$addressId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro desconhecido',
      };
    }
  }
}
