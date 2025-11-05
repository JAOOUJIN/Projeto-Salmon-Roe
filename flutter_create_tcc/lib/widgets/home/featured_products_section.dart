import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  final List<ProductModel> products;

  const FeaturedProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Destaques",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                ProductCard(product: products[index]),
          ),
        ),
      ],
    );
  }
}
