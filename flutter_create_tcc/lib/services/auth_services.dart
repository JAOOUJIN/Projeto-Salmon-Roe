// AuthServices: É responsável por toda a comunicação de rede (API)
// relacionada à autenticação do usuário (login e registro)
// Ela isola a lógica de fazer chamadas HTTP e tratar erros de rede

import 'package:dio/dio.dart';
import '../utils/config.dart';

// Serviços de autenticação
class AuthServices {
  final Dio dio = Dio()..interceptors.add(LogInterceptor(responseBody: true, requestBody: true,logPrint: (obj) => print("DIO_DEBUG: $obj")));
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
        '$baseUrl/user/register',
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

  // FORGOT PASSWORD - envia OTP para email
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        '$baseUrl/forgot-password',
        data: {'email': email},
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Erro ao enviar código',
      };
    }
  }

  // REDEFINIR SENHA
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      // DEBUG: Veja no console se os dados estão corretos antes de enviar
      print("Enviando Reset: Email: $email, OTP: $otp, Pass: $newPassword");

      final response = await dio.post(
        '$baseUrl/reset-password',
        data: {
          'email': email,
          'otp': otp, // Garanta que no Go você mudou para "otp"
          'newPassword':
              newPassword, // CamelCase com 'P' maiúsculo conforme o Go
        },
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      // DEBUG: Imprime o erro real do servidor no console do Flutter
      print("Erro no Reset: ${e.response?.data}");

      String errorMsg = 'Erro ao redefinir senha';

      if (e.response?.data != null && e.response?.data is Map) {
        // Tenta pegar a mensagem de erro que vem do Go
        errorMsg =
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            errorMsg;
      }

      return {'success': false, 'error': errorMsg};
    }
  }
}
