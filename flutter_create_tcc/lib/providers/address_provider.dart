import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/address_model.dart';
import '../services/address_services.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> addresses = [];
  String? defaultAddressId;
  bool isLoading = false;
  String? errorMessage;
  String _search = '';

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value.toLowerCase();
    notifyListeners();
  }

  List<AddressModel> get filteredAddresses {
    if (_search.isEmpty) return addresses;

    return addresses.where((a) {
      final text = '${a.street} ${a.number} ${a.neighborhood}'.toLowerCase();
      return text.startsWith(_search) || text.contains(_search);
    }).toList();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

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

  Future<void> useCurrentLocation() async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Verificar e solicitar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão de localização negada permanentemente. Habilite nas configurações.',
        );
      }

      // 2. Obter posição atual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      // 3. Converter coordenadas em endereço
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception(
          'Não foi possível obter o endereço da localização atual.',
        );
      }

      final place = placemarks.first;

      // 4. AddressModel temporário
      final tempAddress = AddressModel(
        id: 'current_location_${DateTime.now().millisecondsSinceEpoch}',
        street: place.thoroughfare ?? place.street ?? 'Rua desconhecida',
        number: place.subThoroughfare ?? place.subAdministrativeArea ?? '',
        neighborhood: place.subLocality ?? place.locality ?? '',
        city: place.locality ?? place.administrativeArea ?? '',
        state: place.administrativeArea ?? '',
        zip: place.postalCode ?? '',
        complement: 'Localização atual (GPS)',
      );

      // 5. Selecionar como endereço ativo
      selectAddress(tempAddress);

      debugPrint(
        'Endereço atual definido: ${tempAddress.street}, ${tempAddress.number}',
      );
    } catch (e) {
      _setError(e.toString().replaceAll('Exception:', '').trim());
      debugPrint('Erro ao usar localização atual: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    addresses = [];
    defaultAddressId = null;
    notifyListeners();
  }
}
