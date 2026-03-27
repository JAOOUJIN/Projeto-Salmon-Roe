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

  // 1. Busca o histórico completo de pedidos do usuário logado
  Future<void> fetchOrders(String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _service.getMyOrders(token: token);

      if (result['success'] == true) {
        // O result['data'] já vem mapeado como List<SaleModel> pelo Service
        _orders = result['data'];
      } else {
        _errorMessage = result['error'] ?? 'Erro ao carregar histórico';
      }
    } catch (e) {
      _errorMessage = 'Ocorreu um erro inesperado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Busca apenas o status do último pedido feito (para a Home/Status)
  Future<void> fetchLastOrderStatus(String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _service.getLastOrderStatus(token: token);

      if (result['success'] == true) {
        // Se o seu service retornar o Map bruto, usamos o fromJson aqui
        // Se o service já converter, basta atribuir
        _lastOrder = SaleModel.fromJson(result['data']);
      } else {
        _lastOrder = null;
        _errorMessage = result['error'] ?? 'Nenhum pedido ativo encontrado';
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar pedido: $e';
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
