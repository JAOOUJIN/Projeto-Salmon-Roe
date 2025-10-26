import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import 'confirm_address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _openConfirmAddressScreen() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
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

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
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


    if (!mounted) return;

    if (result != null) {
      // Vai para ReviewOrderScreen com os dados
      Navigator.pushNamed(
        context,
        '/reviewOrder',
        arguments: result, // Passa endereço, entrega, pagamento.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacola'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 248, 135, 43),
      ),
      body: cartProvider.items.isEmpty
          ? const Center(
              child: Text(
                'Seu Carrinho está vazio',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      final ProductModel product = item['product'];
                      final int quantity = item['quantity'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.imageUrl.isNotEmpty
                                ? Image.network(
                                    product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 40,
                                  ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'R\$ ${(product.price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    cartProvider.updateQuantity(
                                      product,
                                      quantity - 1,
                                    );
                                  } else {
                                    cartProvider.removeFromCart(product);
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () {
                                  cartProvider.updateQuantity(
                                    product,
                                    quantity + 1,
                                  );
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _CartSummarySection(
                  cartProvider: cartProvider,
                  onContinuePressed: _openConfirmAddressScreen,
                ),
              ],
            ),
    );
  }
}

class _CartSummarySection extends StatelessWidget {
  final CartProvider cartProvider;
  final VoidCallback onContinuePressed;

  const _CartSummarySection({
    required this.cartProvider,
    required this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${cartProvider.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onContinuePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 241, 133, 60),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continuar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
