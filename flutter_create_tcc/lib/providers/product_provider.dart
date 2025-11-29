// 📦 ProductProvider: Gerencia o estado e o catálogo de produtos disponíveis na aplicação
// Responsável pela comunicação com o serviço (Service Layer) para buscar os dados
// e fornecer listas filtradas (destaques, novidades) para a camada de visualização (UI)
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_services.dart';

class ProductProvider extends ChangeNotifier {
  // Instância do serviço responsável por buscar os produtos
  // O Provider delega a responsabilidade de comunicação com a API (ou banco de dados) ao Service
  final ProductServices _service = ProductServices();

  // Lista principal que armazena todos os produtos carregados
  List<ProductModel> products = [];

  // Indica o estado atual de carregamento (útil para feedback visual na UI)
  bool isLoading = false;

  // Busca os produtos do serviço e atualiza o estado
  // Notifica os listeners antes e depois da operação para atualizar a UI
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners(); // 1. Inicia o estado de carregamento e notifica os widgets

    try {
      // 2. Delega a busca de dados para o serviço (separação de responsabilidades)
      products = await _service.getProducts(); // Busca os produtos.
    } catch (e) {
      debugPrint("Erro ao carregar produtos: $e"); // Log de erro.
    }

    isLoading = false;
    notifyListeners(); // 3. Finaliza o estado de carregamento e notifica a UI com os dados ou o erro
  }

  // Getter filtrado: Retorna apenas os produtos destacados (featured), baseado na propriedade do modelo
  List<ProductModel> get featured =>
      products.where((p) => p.isFeatured).toList();

  // Getter filtrado: Retorna apenas os produtos novos (new)
  List<ProductModel> get newProducts => products.where((p) => p.isNew).toList();
}
