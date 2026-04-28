import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../services/sale_services.dart';

class OrdersProvider with ChangeNotifier {
  // Instância do serviço para comunicação com a API em Node.js
  final SaleServices _service = SaleServices();

  // Estado interno
  List<SaleModel> _orders = [];
  SaleModel? _lastOrder;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters públicos para a UI (Seguindo seu padrão de imutabilidade)
  List<SaleModel> get orders => List.unmodifiable(_orders);
  SaleModel? get lastOrder => _lastOrder;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // 1. Busca o histórico completo de pedidos
  Future<void> fetchOrders(String token) async {
    _isLoading = true;
    _errorMessage = '';

    try {
      final result = await _service.getMyOrders(token: token);

      if (result['success'] == true) {
        _orders = result['data'] ?? [];
      } else {
        _orders = [];
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar histórico: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Busca apenas o status do último pedido
  Future<void> fetchLastOrderStatus(String token) async {
    _isLoading = true;
    _errorMessage = '';

    try {
      final result = await _service.getLastOrderStatus(token: token);

      if (result['success'] == true && result['data'] != null) {
        _lastOrder = SaleModel.fromJson(result['data']);
      } else {
        _lastOrder = null;
      }
    } catch (e) {
      _lastOrder = null;
      debugPrint("Erro ao buscar último pedido: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Limpa os dados (útil para quando o usuário fizer Logout)
  void clearOrders() {
    _orders = [];
    _lastOrder = null;
    _errorMessage = '';
    notifyListeners();
  }

  // 4. Getter para facilitar filtros rápidos no histórico, se necessário
  List<SaleModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }
}
