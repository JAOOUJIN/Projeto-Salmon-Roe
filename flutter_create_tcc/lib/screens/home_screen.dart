import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/screens/cart/cart_screen.dart';
import 'package:flutter_create_tcc/models/address_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_create_tcc/screens/profile/address/address_screen.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;
  String currentAddress = "Selecione um endereço";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<ProductProvider>().fetchProducts();
      _loadDefaultAddress();
      _initialized = true;
    }
  }

  void _loadDefaultAddress() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final addresses = auth.user?.addresses ?? [];
    final defaultId = auth.user?.defaultAddressId;

    if (addresses.isNotEmpty && defaultId != null) {
      final defaultAddress = addresses.firstWhere(
        (addr) => addr.id == defaultId,
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

      if (defaultAddress.id.isNotEmpty) {
        setState(() {
          currentAddress = "${defaultAddress.street}, ${defaultAddress.number}";
        });
      }
    }
  }

  void _updateAddress(String newAddress) {
    setState(() {
      currentAddress = newAddress;
    });
  }

  Future<void> _openAddressScreen() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
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

    if (result != null) {
      final street = result["street"] ?? "";
      final number = result["number"] ?? "";
      final newAddress = "$street, $number";
      _updateAddress(newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final featured = provider.featured;
    final newProducts = provider.newProducts;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: GestureDetector(
            onTap: _openAddressScreen,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    currentAddress,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cartProvider.items.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartProvider.items.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                const Text(
                  "Destaques",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) =>
                        ProductCard(product: featured[index]),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Lançamentos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...newProducts.map((p) => ProductCard(product: p)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
