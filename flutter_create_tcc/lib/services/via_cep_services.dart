import 'package:dio/dio.dart';

class ViaCepService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> buscarEnderecoPorCep(String cep) async {
    try {
      final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');

      if (response.statusCode == 200 && response.data['erro'] != true) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {'success': false, 'error': 'CEP não encontrado.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erro ao buscar CEP: $e'};
    }
  }
}
