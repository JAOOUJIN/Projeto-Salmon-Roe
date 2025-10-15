import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final Dio dio = Dio();
  final String baseUrl = "http://10.0.2.2:5000/api/auth";

  // REGISTER
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/register',
        data: {'email': email, 'password': password, 'phone': phone},
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Erro desconhecido',
      };
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/login',
        data: {'loginId': loginId, 'password': password},
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Erro desconhecido',
      };
    }
  }

  // UPDATE USER DATA
  Future<Map<String, dynamic>> updateUserData({
    required String token,
    required String userId,
    String? name,
    String? cpf,
  }) async {
    final url = Uri.parse('$baseUrl/update-info/$userId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'cpf': cpf}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'error': data['error'] ?? 'Erro desconhecido.'};
    }
  }

  // UPDATE ACCESS INFO
  Future<Map<String, dynamic>> updateAccessInfo({
    required String token,
    required String userId,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-access/$userId',
        data: {
          if (phone != null) 'phone': phone,
          if (currentPassword != null) 'currentPassword': currentPassword,
          if (newPassword != null) 'newPassword': newPassword,
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
            : 'Erro desconhecido',
      };
    }
  }
}
