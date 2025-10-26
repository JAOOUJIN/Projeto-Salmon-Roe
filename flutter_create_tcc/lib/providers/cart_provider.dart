import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../services/sale_services.dart';

class CartProvider with ChangeNotifier {
  final SaleServices _saleService = SaleServices();

  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  double get totalPrice => _items.fold(
    0,
    (sum, item) => sum + (item['product'].price * item['quantity']),
  );

  CartProvider() {
    loadCart(); 
  }

  // Carrega o carrinho salvo do SharedPreferences
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
      notifyListeners();
    }
  }

  // Salva o carrinho no SharedPreferences
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

  // Adiciona produto ao carrinho
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

  // Adiciona quantidade específica
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

  // Remove produto do carrinho
  void removeFromCart(ProductModel product) {
    _items.removeWhere((item) => item['product'].id == product.id);
    _saveCart();
    notifyListeners();
  }

  // Atualiza quantidade de um item
  void updateQuantity(ProductModel product, int quantity) {
    final index = _items.indexWhere((item) => item['product'].id == product.id);
    if (index >= 0 && quantity > 0) {
      _items[index]['quantity'] = quantity;
      _saveCart();
      notifyListeners();
    }
  }

  // Esvazia o carrinho
  void clearCart() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
    notifyListeners();
  }

  // Cria uma venda no backend
  Future<Map<String, dynamic>> createSale(String token, int saleCode) async {
    if (_items.isEmpty) {
      return {'success': false, 'error': 'Carrinho vazio.'};
    }

    _isLoading = true;
    notifyListeners();

    try {
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
        clearCart();
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
