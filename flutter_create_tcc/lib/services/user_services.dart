// UserServices: Esta classe gerencia todas as operações de comunicação de rede (API)
// relacionadas ao perfil do usuário (atualizações de dados, senhas)
// Todas as operações requerem o token de autenticação para identificar o usuário

import 'package:dio/dio.dart';
import '../utils/config.dart';

// Serviços de usuário
class UserServices {
  final Dio dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
        logPrint: (obj) => print("DIO_DEBUG: $obj"),
      ),
    );
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
        data: {'name': name, 'cpf': cpf},
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
          'phone': ?phone,
          'currentPassword': ?currentPassword,
          'newPassword': ?newPassword,
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
}
