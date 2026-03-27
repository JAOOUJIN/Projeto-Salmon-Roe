// SaleServices: É responsável por todas as operações de comunicação
// de rede (API) relacionadas às vendas (criação e busca de histórico)
// Ela exige autenticação (token) para garantir que as operações sejam seguras

import 'package:dio/dio.dart';
import '../utils/config.dart';
import '../models/sale_model.dart';

class SaleServices {
  final Dio dio = Dio();
  final String baseUrl =
      "${Config.baseUrl}/sales"; // Endereço base para as rotas de venda

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

  //  Buscar APENAS os pedidos do usuário logado 
  Future<Map<String, dynamic>> getMyOrders({required String token}) async {
    try {
      final response = await dio.get(
        '$baseUrl/my-orders', // Rota específica do usuário
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final sales = (response.data as List<dynamic>)
          .map((e) => SaleModel.fromJson(e))
          .toList();

      return {'success': true, 'data': sales};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Erro ao carregar seus pedidos',
      };
    }
  }

  // Buscar TODAS as vendas 
  Future<Map<String, dynamic>> getAllSales({required String token}) async {
    try {
      final response = await dio.get(
        '$baseUrl/', // Rota raiz do recurso sales
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final sales = (response.data as List<dynamic>)
          .map((e) => SaleModel.fromJson(e))
          .toList();

      return {'success': true, 'data': sales};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Erro ao carregar vendas gerais',
      };
    }
  }

  // Buscar status do último pedido ativo 
  Future<Map<String, dynamic>> getLastOrderStatus({
    required String token,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/last-order-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Erro ao buscar pedido ativo',
      };
    }
  }

  // Buscar detalhes de uma venda específica por ID 
  Future<Map<String, dynamic>> getSaleById({
    required String token,
    required String id,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Erro ao buscar pedido',
      };
    }
  }
}
