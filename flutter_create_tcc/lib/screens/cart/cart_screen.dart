import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/cart/cart_items_list.dart';
import '../../widgets/cart/cart_summary_section.dart';
import 'confirm_address_screen.dart';
import 'review_order_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openConfirmAddressScreen() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );

    // Verificação de login
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Faça login para continuar a compra."),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamed(context, '/clientProfile');
      return;
    }

    // ✅ Novo: Usa selectedAddress do provider (inclui seleção manual)
    final initialAddress = addressProvider.selectedAddress;
    if (initialAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um endereço primeiro.")),
      );
      return;
    }

    if (!mounted) return;

    final localContext = context;

    // ✅ Ajustado: Modal retorna AddressModel
    final result = await showModalBottomSheet<AddressModel>(
      context: localContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ConfirmAddressScreen(initialAddress: initialAddress),
      ),
    );

    if (!mounted || result == null) return;

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    // ✅ Ajustado: Passa AddressModel para ReviewOrderScreen
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => ReviewOrderScreen(
          address: result, // AddressModel
          delivery: "Padrão", // Ou passe dinamicamente se necessário
        ),
        transitionsBuilder: (_, animation, __, child) {
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );
          return SlideTransition(position: slideAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    context.watch<AuthProvider>();
    context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Carrinho',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: cartProvider.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Seu carrinho está vazio',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: CartItemsList(cartProvider: cartProvider)),
                    CartSummarySection(
                      cartProvider: cartProvider,
                      onContinuePressed: _openConfirmAddressScreen,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
