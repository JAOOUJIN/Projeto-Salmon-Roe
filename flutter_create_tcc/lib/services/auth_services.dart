import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio();
  final String baseUrl = "http://10.0.2.2:5000/api/auth";

  Future<Map<String, dynamic>> register(String email, String password, String phone) async {
    try {
      final response = await dio.post(
        '$baseUrl/register',
        data: {
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error']};
    }
  }

  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/login',
        data: {
          'loginId': loginId,
          'password': password,
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error']};
    }
  }
}