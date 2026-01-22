import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_services.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> addresses = [];
  String? defaultAddressId;
  bool isLoading = false;

  Future<void> fetchAddresses(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getAddresses(token);

      addresses = (result['addresses'] as List)
          .map((e) => AddressModel.fromJson(e))
          .toList();

      defaultAddressId = result['defaultAddressId'];
    } catch (e) {
      debugPrint('Erro ao buscar endereços: $e');
    }

    isLoading = false;
    notifyListeners();

    if (_selectedAddress != null) {
      final exists = addresses.any((a) => a.id == _selectedAddress!.id);
      if (!exists) {
        _selectedAddress = null;
      }
    }
  }

  AddressModel? _selectedAddress;

  AddressModel? get selectedAddress => _selectedAddress ?? defaultAddress;

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clearSelection() {
    _selectedAddress = null;
    notifyListeners();
  }

  AddressModel? get defaultAddress {
    if (defaultAddressId == null || addresses.isEmpty) return null;
    try {
      return addresses.firstWhere((a) => a.id == defaultAddressId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addAddress({
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
      addresses = await _service.addAddress(token, {
        'street': street,
        'number': number,
        'city': city,
        'state': state,
        'zip': zip,
        'neighborhood': neighborhood,
        'complement': complement,
      });
    } catch (e) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> updateAddress({
    required String token,
    required String addressId,
    required String street,
    required String number,
    required String city,
    required String state,
    required String zip,
    required String neighborhood,
    String? complement,
  }) async {
    try {
      addresses = await _service.updateAddress(token, addressId, {
        'street': street,
        'number': number,
        'city': city,
        'state': state,
        'zip': zip,
        'neighborhood': neighborhood,
        'complement': complement,
      });
    } catch (e) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> deleteAddress(String token, String addressId) async {
    addresses = await _service.deleteAddress(token, addressId);
    notifyListeners();
  }

  Future<void> setDefault(String token, String addressId) async {
    defaultAddressId = await _service.setDefaultAddress(token, addressId);

    _selectedAddress = addresses.firstWhere(
      (a) => a.id == addressId,
      orElse: () => _selectedAddress!,
    );

    notifyListeners();
  }

  void clear() {
    addresses = [];
    defaultAddressId = null;
    notifyListeners();
  }
}
