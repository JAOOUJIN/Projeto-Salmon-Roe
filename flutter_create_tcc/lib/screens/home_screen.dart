import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/screens/profile/address/address_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final String currentAddress;
  final Function(String) onAddressChanged;

  const HomeScreen({
    super.key,
    required this.currentAddress,
    required this.onAddressChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<ProductProvider>().fetchProducts();
      _initialized = true;
    }
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
      widget.onAddressChanged(newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final featured = provider.featured;
    final newProducts = provider.newProducts;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: provider.fetchProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openAddressScreen,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.currentAddress,
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
              const SizedBox(height: 20),

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
    );
  }
}
