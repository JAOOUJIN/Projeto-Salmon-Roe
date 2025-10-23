import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductServices {
  final Dio dio = Dio();
  final String baseUrl = "http://10.0.2.2:5000/api/products";

  // Listar todos os produtos (sem token)
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get(baseUrl);

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
