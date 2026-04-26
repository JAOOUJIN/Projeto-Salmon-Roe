import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../services/sale_services.dart';

class CartProvider with ChangeNotifier {
  final SaleServices _saleService = SaleServices();

  // O carrinho é uma lista de Maps, onde cada Map contém o objeto ProductModel e a quantidade
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  // Retorna uma lista imutável (não pode ser modificada diretamente)
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  // Calcula o preço total do carrinho usando o método fold (agregação)
  double get totalPrice => _items.fold(
    0,
    (sum, item) => sum + (item['product'].price * item['quantity']),
  );

  CartProvider() {
    loadCart(); // 1. Garante que o carrinho seja carregado do disco na inicialização
  }

  // Carrega o carrinho salvo do SharedPreferences
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items');

    if (cartData != null) {
      final decoded = jsonDecode(cartData) as List<dynamic>;

      _items.clear();
      // 1. Mapeia os dados decodificados para recriar os objetos ProductModel e a lista de itens
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
    // 1. Mapeia _items para um formato JSON serializável antes de salvar
    final data = _items
        .map(
          (item) => {
            'product': item['product']
                .toJson(), // Converte o modelo do produto para JSON
            'quantity': item['quantity'],
          },
        )
        .toList();
    await prefs.setString('cart_items', jsonEncode(data));
  }

  // Adiciona produto ao carrinho
  void addToCart(ProductModel product) {
    // 1. Tenta encontrar o produto existente
    final index = _items.indexWhere((item) => item['product'].id == product.id);

    if (index >= 0) {
      _items[index]['quantity'] += 1; // 2. Se existe, incrementa a quantidade
    } else {
      _items.add({
        'product': product,
        'quantity': 1,
      }); // 3. Se não existe, adiciona como novo item
    }

    _saveCart(); // 4. Persiste a mudança
    notifyListeners();
  }

  // Adiciona quantidade específica
  void addItem(ProductModel product, int quantity) {
    final index = _items.indexWhere((item) => item['product'].id == product.id);

    if (index >= 0) {
      _items[index]['quantity'] +=
          quantity; // Adiciona a quantidade à existente
    } else {
      _items.add({
        'product': product,
        'quantity': quantity,
      }); // Adiciona o item com a quantidade especificada
    }

    _saveCart();
    notifyListeners();
  }

  // Remove produto do carrinho
  void removeFromCart(ProductModel product) {
    _items.removeWhere(
      (item) => item['product'].id == product.id,
    ); // Remove o Map que contém o produto
    _saveCart();
    notifyListeners();
  }

  // Atualiza quantidade de um item
  void updateQuantity(ProductModel product, int quantity) {
    final index = _items.indexWhere((item) => item['product'].id == product.id);
    // 1. Garante que o item exista e que a nova quantidade seja válida
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
    await prefs.remove('cart_items'); // 1. Limpa o SharedPreferences
    notifyListeners();
  }

  // Cria uma venda no backend
  Future<Map<String, dynamic>> createSale(
    String token,
    int saleCode, {
    required String address,
    required String delivery,
    required String payment,
    bool hasActiveOrder = false,
  }) async {
    if (_items.isEmpty) {
      return {'success': false, 'error': 'Carrinho vazio.'};
    }

    if (hasActiveOrder) {
      return {
        'success': false,
        'error': 'Você já possui um pedido em andamento. Aguarde a finalização para fazer um novo pedido.',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Converte os itens do carrinho para a estrutura SaleItem esperada pelo serviço de API
      final saleItems = _items
          .map(
            (item) => SaleItem(
              productId: item['product'].id.toString(),
              quantity: item['quantity'],
              unitPrice: item['product'].price,
            ),
          )
          .toList();

      final result = await _saleService.createSale(
        token: token, // Requer o token de autenticação para criar a venda
        saleCode: saleCode,
        items: saleItems,
        address: address,
        delivery: delivery,
        payment: payment,
      );

      if (result['success'] == true) {
        clearCart(); // 2. Se a venda for bem-sucedida, limpa o carrinho
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
