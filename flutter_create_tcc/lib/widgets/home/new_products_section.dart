import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'product_card.dart';

class NewProductsSection extends StatelessWidget {
  final List<ProductModel> products;

  const NewProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lançamentos",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: products.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProductCard(
                product: p,
                isWide: true,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
