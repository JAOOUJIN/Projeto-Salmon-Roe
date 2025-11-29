// CartProvider gerencia o estado do carrinho de compras.
// Ele permite adicionar, remover, atualizar itens, calcular o valor total,
// persistir o carrinho localmente usando SharedPreferences e criar vendas no backend.
// Utiliza ChangeNotifier para notificar widgets sobre mudanças no estado do carrinho.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../services/sale_services.dart';

class CartProvider with ChangeNotifier {
  final SaleServices _saleService = SaleServices();

  // Lista de itens do carrinho, cada item é um mapa com produto e quantidade
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  // Retorna uma lista imutável dos itens do carrinho
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  // Calcula o preço total do carrinho
  double get totalPrice => _items.fold(
    0,
    (sum, item) => sum + (item['product'].price * item['quantity']),
  );

  CartProvider() {
    loadCart(); // Carrega o carrinho salvo ao inicializar o provider
  }

  /// Carrega o carrinho salvo do SharedPreferences
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items');
 
    if (cartData != null) {
      final decoded = jsonDecode(cartData) as List<dynamic>;

      _items.clear();
      _items.addAll(
        decoded.map((item) {
          return {
            'product': ProductModel.fromJson(item['product']),
            'quantity': item['quantity'],
          };
        }).toList(),
      );
      notifyListeners(); // Notifica listeners após carregar os itens
    }
  }

  /// Salva o carrinho no SharedPreferences
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items
        .map(
          (item) => {
            'product': item['product'].toJson(),
            'quantity': item['quantity'],
          },
        )
        .toList();
    await prefs.setString('cart_items', jsonEncode(data));
  }

  /// Adiciona um produto ao carrinho (incrementa quantidade se já existir)
  void addToCart(ProductModel product) {
    final index = _items.indexWhere((item) => item['product'].id == product.id);

    if (index >= 0) {
      _items[index]['quantity'] += 1;
    } else {
      _items.add({'product': product, 'quantity': 1});
    }

    _saveCart();
    notifyListeners();
  }

  /// Adiciona uma quantidade específica de um produto ao carrinho
  void addItem(ProductModel product, int quantity) {
    final index = _items.indexWhere((item) => item['product'].id == product.id);

    if (index >= 0) {
      _items[index]['quantity'] += quantity;
    } else {
      _items.add({'product': product, 'quantity': quantity});
    }

    _saveCart();
    notifyListeners();
  }

  /// Remove um produto do carrinho
  void removeFromCart(ProductModel product) {
    _items.removeWhere((item) => item['product'].id == product.id);
    _saveCart();
    notifyListeners();
  }

  /// Atualiza a quantidade de um produto no carrinho
  void updateQuantity(ProductModel product, int quantity) {
    final index = _items.indexWhere((item) => item['product'].id == product.id);
    if (index >= 0 && quantity > 0) {
      _items[index]['quantity'] = quantity;
      _saveCart();
      notifyListeners();
    }
  }

  /// Esvazia o carrinho e remove do SharedPreferences
  void clearCart() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
    notifyListeners();
  }

  /// Cria uma venda no backend usando os itens do carrinho
  /// Retorna um mapa com sucesso ou erro
  Future<Map<String, dynamic>> createSale(String token, int saleCode) async {
    if (_items.isEmpty) {
      return {'success': false, 'error': 'Carrinho vazio.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Converte os itens do carrinho para SaleItem para enviar ao backend
      final saleItems = _items
          .map(
            (item) => SaleItem(
              productId: item['product'].id.toString(),
              quantity: item['quantity'],
            ),
          )
          .toList();

      final result = await _saleService.createSale(
        token: token,
        saleCode: saleCode,
        items: saleItems,
      );

      if (result['success'] == true) {
        clearCart(); // Limpa o carrinho após venda bem-sucedida
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }
}
