import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

class CartItemsList extends StatelessWidget {
  final CartProvider cartProvider;

  const CartItemsList({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cartProvider.items.length,
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        final ProductModel product = item['product'];
        final int quantity = item['quantity'];

        // Animação individual para cada item
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 350 + (index * 80)),
          curve: Curves.easeOut,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageUrl,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported_outlined, size: 40),
                ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'R\$ ${(product.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        cartProvider.updateQuantity(product, quantity - 1);
                      } else {
                        cartProvider.removeFromCart(product);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () =>
                        cartProvider.updateQuantity(product, quantity + 1),
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
