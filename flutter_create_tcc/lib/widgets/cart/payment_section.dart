import 'package:flutter/material.dart';

class PaymentSection extends StatelessWidget {
  final String selectedPayment;
  final Function(String) onPaymentSelected;

  const PaymentSection({
    super.key,
    required this.selectedPayment,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Forma de Pagamento",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Opção: Pagar quando chegar
        _buildPaymentOption(
          id: "Pagar quando chegar",
          title: "Pagar quando chegar",
          subtitle: "Pagamento na entrega",
          icon: Icons.payments_outlined,
        ),

        const SizedBox(height: 10),

        // Opção: Pix
        _buildPaymentOption(
          id: "Pix",
          title: "Pix",
          subtitle: "Aprovação instantânea",
          imagePath: 'assets/images/logo_pix.png', 
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    IconData? icon,
    String? imagePath,
  }) {
    bool isSelected = selectedPayment == id;

    return GestureDetector(
      onTap: () => onPaymentSelected(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.redAccent.withValues(alpha: 0.2)
                  : Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          leading: imagePath != null
              ? Image.asset(imagePath, width: 24, height: 24)
              : Icon(icon, color: isSelected ? Colors.redAccent : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.redAccent)
              : const Icon(Icons.circle_outlined, color: Colors.grey),
        ),
      ),
    );
  }
}
