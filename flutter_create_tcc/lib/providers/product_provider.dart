// ProductProvider gerencia o estado dos produtos na aplicação.
// Ele é responsável por buscar os produtos, armazená-los e disponibilizar listas filtradas (destaques e novos).

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_services.dart';

class ProductProvider extends ChangeNotifier {
  // Instância do serviço responsável por buscar os produtos.
  final ProductServices _service = ProductServices();

  // Lista de produtos carregados.
  List<ProductModel> products = [];

  // Indica se os produtos estão sendo carregados.
  bool isLoading = false;

  // Busca os produtos do serviço e atualiza o estado.
  // Notifica os listeners antes e depois da operação.
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners(); // Notifica que o carregamento começou.

    try {
      products = await _service.getProducts(); // Busca os produtos.
    } catch (e) {
      debugPrint("Erro ao carregar produtos: $e"); // Log de erro.
    }

    isLoading = false;
    notifyListeners(); // Notifica que o carregamento terminou.
  }

  // Retorna apenas os produtos destacados (featured).
  List<ProductModel> get featured =>
      products.where((p) => p.isFeatured).toList();

  // Retorna apenas os produtos novos (new).
  List<ProductModel> get newProducts => products.where((p) => p.isNew).toList();
}
