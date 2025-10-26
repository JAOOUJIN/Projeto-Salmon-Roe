import 'package:dio/dio.dart';

// Serviços de usuário

class UserServices {
  final Dio dio = Dio();
  final String baseUrl = "http://10.0.2.2:5000/api/user"; 

  // UPDATE USER DATA (nome, CPF) - Removido userId da URL
  Future<Map<String, dynamic>> updateUserData({
    required String token,
    String? name,
    String? cpf,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-info',  // URL sem :id
        data: {
          if (name != null) 'name': name,
          if (cpf != null) 'cpf': cpf,
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

  // UPDATE ACCESS INFO (telefone, senha) - Removido userId da URL
  Future<Map<String, dynamic>> updateAccessInfo({
    required String token,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-access',  // URL sem :id
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

  // GET ADDRESSES 
  Future<Map<String, dynamic>> getAddresses({required String token}) async {
    try {
      final response = await dio.get(
        '$baseUrl/',  // URL para listar endereços
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

  // ADD ADDRESS 
  Future<Map<String, dynamic>> addAddress({
    required String token,
    required String street,
    required String number,
    required String city,
    required String state,
    required String zip,
    required String neighborhood,
    String? complement,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/address',  
        data: {
          'street': street,
          'number': number,
          'city': city,
          'state': state,
          'zip': zip,
          'neighborhood': neighborhood,
          'complement': complement,
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

  // SET DEFAULT ADDRESS 
Future<Map<String, dynamic>> setDefaultAddress({
  required String token,
  required String addressId,
}) async {
  try {
    final response = await dio.put(
      '$baseUrl/set-default-address/$addressId',  
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

  // UPDATE ADDRESS 
  Future<Map<String, dynamic>> updateAddress({
    required String token,
    required String addressId,
    String? street,
    String? number,
    String? city,
    String? state,
    String? zip,
    String? neighborhood,
    String? complement,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/address/$addressId',  
        data: {
          if (street != null) 'street': street,
          if (number != null) 'number': number,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (zip != null) 'zip': zip,
          if (neighborhood != null) 'neighborhood': neighborhood,
          if (complement != null) 'complement': complement,
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

  // DELETE ADDRESS 
  Future<Map<String, dynamic>> deleteAddress({
    required String token,
    required String addressId,
  }) async {
    try {
      final response = await dio.delete(
        '$baseUrl/address/$addressId',  
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