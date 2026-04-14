import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../widgets/cart/payment_section.dart';
import '../../widgets/cart/order_summary_section.dart';
import '../../widgets/cart/order_review_modal.dart';

class ReviewOrderScreen extends StatefulWidget {
  final AddressModel address;
  final String delivery;

  const ReviewOrderScreen({
    super.key,
    required this.address,
    required this.delivery,
  });

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  String selectedPayment = "Pagar quando chegar";

  void _showReviewModal() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OrderReviewModal(
          // Passamos o endereço formatado
          address: "${widget.address.street}, ${widget.address.number}",
          delivery: widget.delivery,
          payment: selectedPayment,
          cartProvider: cartProvider,
          authProvider: authProvider,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Revisar Pedido",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de seleção de pagamento (Pix ou Entrega)
            PaymentSection(
              selectedPayment: selectedPayment,
              onPaymentSelected: (value) {
                setState(() {
                  selectedPayment = value;
                });
              },
            ),
            const SizedBox(height: 24),

            OrderSummarySection(cartProvider: cartProvider),
            const Spacer(),
            // BOTÃO ÚNICO: Revisar Pedido
            ElevatedButton(
              onPressed: _showReviewModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4C4C),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: Colors.black26,
              ),
              child: const Text(
                "Revisar Pedido",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
