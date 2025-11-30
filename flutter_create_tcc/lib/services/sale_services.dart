// SaleServices: É responsável por todas as operações de comunicação
// de rede (API) relacionadas às vendas (criação e busca de histórico)
// Ela exige autenticação (token) para garantir que as operações sejam seguras

import 'package:dio/dio.dart';
import '../utils/config.dart';
import '../models/sale_model.dart';

class SaleServices {
  final Dio dio = Dio();
  final String baseUrl =
      "${Config.baseUrl}/sale"; // Endereço base para as rotas de venda

  // Criar nova venda (Requer autenticação)
  Future<Map<String, dynamic>> createSale({
    required String token, // Token de autenticação do usuário
    required int saleCode,
    required List<SaleItem>
    items, // Lista de itens a serem vendidos (modelos Dart)
  }) async {
    try {
      // Faz a requisição POST para criar a venda
      final response = await dio.post(
        baseUrl,
        data: {
          'cd_venda': saleCode,
          // Mapeia a lista de objetos SaleItem (Dart) para uma lista de Maps (JSON) para envio
          'itens': items.map((e) => e.toJson()).toList(),
        },
        // Inclui o token no cabeçalho 'Authorization' para autenticar a requisição
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros de requisição, buscando a mensagem de erro mais relevante do servidor
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro ao criar venda',
      };
    }
  }

  // Buscar histórico de vendas (Requer autenticação)
  Future<Map<String, dynamic>> getSales({required String token}) async {
    try {
      // Faz a requisição GET para buscar o histórico de vendas do usuário
      final response = await dio.get(
        baseUrl,
        // Inclui o token no cabeçalho
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Mapeia a lista de Maps (JSON) recebida para uma lista de objetos SaleModel
      final sales = (response.data as List<dynamic>)
          .map((e) => SaleModel.fromJson(e))
          .toList();

      return {
        'success': true,
        'data': sales,
      }; // Retorna a lista de objetos SaleModel
    } on DioException catch (e) {
      final err = e.response?.data;
      // Trata erros de requisição, retornando a mensagem de erro do servidor
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro ao carregar histórico',
      };
    }
  }
}
