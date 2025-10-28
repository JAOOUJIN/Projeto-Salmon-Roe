import 'package:flutter/material.dart';
import 'quantity_selector.dart';
import 'add_to_cart_button.dart';

class BottomActionSection extends StatefulWidget {
  final int quantity;
  final double price;
  final VoidCallback onAddQuantity;
  final VoidCallback onRemoveQuantity;
  final VoidCallback onAddToCart;

  const BottomActionSection({
    super.key,
    required this.quantity,
    required this.price,
    required this.onAddQuantity,
    required this.onRemoveQuantity,
    required this.onAddToCart,
  });

  @override
  State<BottomActionSection> createState() => _BottomActionSectionState();
}

class _BottomActionSectionState extends State<BottomActionSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 20),
          child: Row(
            children: [
              // Quantidade 
              Expanded(
                flex: 1,
                child: QuantitySelector(
                  quantity: widget.quantity,
                  onAdd: widget.onAddQuantity,
                  onRemove: widget.onRemoveQuantity,
                ),
              ),
              const SizedBox(width: 12),

              // Botão de adicionar 
              Expanded(
                flex: 2,
                child: AddToCartButton(
                  price: widget.price,
                  onPressed: widget.onAddToCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
