import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_create_tcc/models/address_model.dart';
import 'package:flutter_create_tcc/screens/profile/address/address_screen.dart';
import 'package:flutter_create_tcc/providers/address_provider.dart';
import 'package:flutter_create_tcc/providers/product_provider.dart';
import 'package:flutter_create_tcc/providers/cart_provider.dart';
import 'package:flutter_create_tcc/providers/auth_provider.dart';
import '../../widgets/home/featured_products_section.dart';
import '../../widgets/home/new_products_section.dart';
import '../../widgets/home/notification_icon.dart';
import '../../widgets/home/floating_cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        await context.read<AddressProvider>().fetchAddresses(auth.token!);
      }
    });
  }

  Future<void> _openAddressScreen() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Verificação de login
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Faça login para adicionar ou verificar endereços."),
          duration: Duration(seconds: 3),
        ),
      );
      // Redireciona para o perfil
      Navigator.pushNamed(context, '/clientProfile');
      return;
    }

    await showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: const AddressScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentAddress = addressProvider.selectedAddress != null
        ? "${addressProvider.selectedAddress!.street}, ${addressProvider.selectedAddress!.number}"
        : "Selecione um endereço";

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          surfaceTintColor: Colors.transparent,
          title: GestureDetector(
            onTap: _openAddressScreen,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    currentAddress,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black87,
                  size: 22,
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: NotificationIcon(notificationCount: 3),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: provider.fetchProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeaturedProductsSection(products: provider.featured),
                const SizedBox(height: 20),
                NewProductsSection(products: provider.newProducts),
              ],
            ),
          ),
        ),
        floatingActionButton: cartProvider.items.isNotEmpty
            ? const FloatingCartButton()
            : null,
      ),
    );
  }
}
