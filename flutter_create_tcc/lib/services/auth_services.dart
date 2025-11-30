// AuthServices: É responsável por toda a comunicação de rede (API)
// relacionada à autenticação do usuário (login e registro)
// Ela isola a lógica de fazer chamadas HTTP e tratar erros de rede

import 'package:dio/dio.dart';
import '../utils/config.dart';

// Serviços de autenticação
class AuthServices {
  final Dio dio = Dio();
  // Monta a URL base para todas as chamadas de autenticação
  final String baseUrl = "${Config.baseUrl}/auth";

  // REGISTER: Envia os dados de registro do novo usuário para o servidor
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
  ) async {
    try {
      // Faz a requisição POST para o endpoint /register
      final response = await dio.post(
        '$baseUrl/register',
        data: {'email': email, 'password': password, 'phone': phone},
      );
      // Retorno de sucesso: inclui os dados da resposta do servidor
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      // Captura e trata erros específicos da rede (DioException).
      // Retorna a mensagem de erro fornecida pelo servidor ou uma mensagem padrão
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Erro desconhecido',
      };
    }
  }

  // LOGIN: Envia as credenciais para o servidor para obter o token de acesso
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      // Faz a requisição POST para o endpoint /login
      final response = await dio.post(
        '$baseUrl/login',
        data: {'loginId': loginId, 'password': password},
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Erro desconhecido',
      };
    }
  }
}
