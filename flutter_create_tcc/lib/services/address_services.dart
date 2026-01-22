import 'package:dio/dio.dart';
import '../utils/config.dart';
import '../models/address_model.dart';

class AddressService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "${Config.baseUrl}/address",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  )..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // GET
  Future<Map<String, dynamic>> getAddresses(String token) async {
    final response = await dio.get('', options: _auth(token));

    return {
      'addresses': response.data['addresses'],
      'defaultAddressId': response.data['defaultAddressId'],
    };
  }

  // ADD
  Future<List<AddressModel>> addAddress(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.post('', data: payload, options: _auth(token));

    final List data = response.data['addresses'];
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  // UPDATE
  Future<List<AddressModel>> updateAddress(
    String token,
    String addressId,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.put(
      '/$addressId',
      data: payload,
      options: _auth(token),
    );

    final List data = response.data['addresses'];
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  // DELETE
  Future<List<AddressModel>> deleteAddress(
    String token,
    String addressId,
  ) async {
    final response = await dio.delete('/$addressId', options: _auth(token));

    final List data = response.data['addresses'];
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  // SET DEFAULT
  Future<String?> setDefaultAddress(String token, String addressId) async {
    final response = await dio.put(
      '/set-default/$addressId',
      options: _auth(token),
    );

    return response.data['user']['defaultAddressId'];
  }
}
