import 'package:flutter/material.dart';

class OrderCardContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const OrderCardContainer({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sombra bem leve, quase imperceptível
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
