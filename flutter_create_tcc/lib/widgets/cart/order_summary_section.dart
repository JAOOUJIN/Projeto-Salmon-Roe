import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';

class OrderSummarySection extends StatelessWidget {
  final CartProvider cartProvider;

  const OrderSummarySection({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Resumo do Pedido",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...cartProvider.items.map((item) {
          final product = item['product'];
          final quantity = item['quantity'];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Quantidade: $quantity"),
              trailing: Text(
                "R\$ ${(product.price * quantity).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          );
        }),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "R\$ ${cartProvider.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
