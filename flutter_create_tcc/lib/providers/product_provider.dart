import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_services.dart';

class ProductProvider extends ChangeNotifier {
  final ProductServices _service = ProductServices();
  List<ProductModel> products = [];
  bool isLoading = false;

  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      products = await _service.getProducts();
    } catch (e) {
      debugPrint("Erro ao carregar produtos: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  List<ProductModel> get featured =>
      products.where((p) => p.isFeatured).toList();

  List<ProductModel> get newProducts =>
      products.where((p) => p.isNew).toList();
}
