// ProductServices: É responsável por buscar dados de produtos da API
// Gerencia a comunicação de rede e a conversão dos dados JSON brutos em objetos Dart (ProductModel)

import 'package:dio/dio.dart';
import '../utils/config.dart';
import '../models/product_model.dart';

class ProductServices {
  final Dio dio =
      Dio(
          BaseOptions(
            // Define a parte inicial do endereço da API para produtos
            baseUrl: "${Config.baseUrl}/products",
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        )
        // Adiciona um interceptador para registrar detalhes das requisições e respostas no console (para debug).
        ..interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true),
        ); // Logs para debug

  // Listar todos os produtos (não requer autenticação/token)
  Future<List<ProductModel>> getProducts() async {
    try {
      // Faz uma requisição GET para a URL base (/products)
      final response = await dio.get('');

      // Verifica se a requisição foi bem-sucedida (status 200 OK)
      if (response.statusCode == 200) {
        final List data = response.data;
        // Mapeia a lista de Maps (JSON) recebida para uma lista de objetos ProductModel
        return data.map((p) => ProductModel.fromJson(p)).toList();
      } else {
        throw Exception("Erro ao carregar produtos");
      }
    } on DioException catch (e) {
      // Captura erros específicos de rede ou servidor (DioException)
      // Lança uma exceção com a mensagem de erro do servidor ou uma mensagem de falha de conexão
      throw Exception(e.response?.data['message'] ?? "Erro de conexão");
    }
  }
}
