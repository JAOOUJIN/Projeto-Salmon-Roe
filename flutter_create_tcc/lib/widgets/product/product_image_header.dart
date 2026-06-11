import 'package:flutter/material.dart';

class ProductImageHeader extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ProductImageHeader({super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}
