import 'package:dio/dio.dart';
import '../models/sale_model.dart';

class SaleServices {
  final Dio dio = Dio();
  final String baseUrl = "http://10.0.2.2:5000/api/sale";

  // Criar nova venda
  Future<Map<String, dynamic>> createSale({
    required String token,
    required int saleCode,
    required List<SaleItem> items,
  }) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: {
          'cd_venda': saleCode,
          'itens': items.map((e) => e.toJson()).toList(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final err = e.response?.data;
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro ao criar venda',
      };
    }
  }

  // Buscar histórico de vendas
  Future<Map<String, dynamic>> getSales({required String token}) async {
    try {
      final response = await dio.get(
        baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final sales = (response.data as List<dynamic>)
          .map((e) => SaleModel.fromJson(e))
          .toList();

      return {'success': true, 'data': sales};
    } on DioException catch (e) {
      final err = e.response?.data;
      return {
        'success': false,
        'error': err != null
            ? (err['error'] ?? err['message'] ?? err)
            : 'Erro ao carregar histórico',
      };
    }
  }
}
