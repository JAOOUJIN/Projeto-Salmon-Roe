import 'package:dio/dio.dart';
import '../utils/config.dart';
import '../models/product_model.dart';

class ProductServices {
  final Dio dio =
      Dio(
          BaseOptions(
            baseUrl:
                "${Config.baseUrl}/products", // Configurando a URL base diretamente
            connectTimeout: const Duration(seconds: 5), // 5 segundos para conectar
            receiveTimeout: const Duration(seconds: 5), // 5 segundos para resposta
          ),
        )
        ..interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true),
        ); // Logs para debug

  // Listar todos os produtos (sem token)
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get('');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((p) => ProductModel.fromJson(p)).toList();
      } else {
        throw Exception("Erro ao carregar produtos");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erro de conexão");
    }
  }
}
