import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "R\$ ${product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.oldPrice > 0) ...[
              const SizedBox(width: 10),
              Text(
                "R\$ ${product.oldPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
