// ViaCepService: É responsável por fazer requisições à API ViaCEP.
// O objetivo é buscar dados de endereço (logradouro, bairro, cidade, estado) a partir de um CEP
// Isola a lógica de rede, garantindo que o Provider receba um resultado consistente (success/error)

import 'package:dio/dio.dart';

class ViaCepService {
  final Dio _dio = Dio();

  // Busca dados de endereço na API ViaCEP
  Future<Map<String, dynamic>> buscarEnderecoPorCep(String cep) async {
    try {
      // 1. Faz a requisição GET, montando a URL com o CEP fornecido
      final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');

      // 2. Verifica o sucesso da requisição HTTP (status 200) E o sucesso lógico da API (ViaCEP usa 'erro': true para CEPs inválidos)
      if (response.statusCode == 200 && response.data['erro'] != true) {
        return {
          'success': true,
          'data': response.data,
        }; // Retorna os dados do endereço
      } else {
        // Trata o caso onde o CEP não é encontrado (erro lógico da ViaCEP)
        return {'success': false, 'error': 'CEP não encontrado.'};
      }
    } catch (e) {
      // 3. Captura erros gerais de rede (como falha de conexão ou timeout)
      return {'success': false, 'error': 'Erro ao buscar CEP: $e'};
    }
  }
}
