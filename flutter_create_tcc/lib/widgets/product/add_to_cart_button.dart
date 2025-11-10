import 'package:flutter/material.dart';

class AddToCartButton extends StatelessWidget {
  final double price;
  final VoidCallback onPressed;

  const AddToCartButton({
    super.key,
    required this.price,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 24),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          colors: [
            Color(
              0xFFE53935,
            ), 
            Color(0xFFEF5350), 
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onPressed,
        splashColor: Colors.white.withValues(alpha: 0.15),
        child: Center(
          child: Text(
            'Adicionar • R\$ ${price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
