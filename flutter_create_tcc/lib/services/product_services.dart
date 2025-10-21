import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductServices {
  final Dio dio = Dio();
  final String baseUrl = "http://10.0.2.2:5000/api/product";

  Future<Map<String, dynamic>> getProducts({required String token}) async {
    try {
      final response = await dio.get(
        baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final products = (response.data as List<dynamic>)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      return {'success': true, 'data': products};
    } on DioException catch (e) {
      final err = e.response?.data;
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro ao carregar produtos',
      };
    }
  }
}
