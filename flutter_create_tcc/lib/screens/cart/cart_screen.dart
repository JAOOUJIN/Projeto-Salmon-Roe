import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
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

    // Verificação de login
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Faça login para continuar a compra."),
          duration: Duration(seconds: 3),
        ),
      );
      // Redireciona para o perfil (que mostra LoggedOutView)
      Navigator.pushNamed(context, '/clientProfile');
      return;
    }

    // Se logado, continua o fluxo normalmente
    final defaultAddress = auth.user?.addresses?.firstWhere(
      (addr) => addr.id == auth.user?.defaultAddressId,
      orElse: () => AddressModel(
        id: '',
        street: '',
        number: '',
        city: '',
        state: '',
        zip: '',
        neighborhood: '',
      ),
    );

    String initialAddress = "Selecione um endereço";
    if (defaultAddress?.id.isNotEmpty == true) {
      initialAddress = "${defaultAddress!.street}, ${defaultAddress.number}";
    }

    if (!mounted) return;

    final localContext = context;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: localContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: ConfirmAddressScreen(initialAddress: initialAddress),
        ),
      ),
    );

    if (!mounted || result == null) return;

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => ReviewOrderScreen(
          address: result['address'] ?? 'Endereço não selecionado',
          delivery: result['delivery'] ?? 'Entrega padrão',
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