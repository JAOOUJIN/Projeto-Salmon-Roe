import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderReviewModal extends StatefulWidget {
  final String address;
  final String delivery;
  final String payment;
  final CartProvider cartProvider;
  final AuthProvider authProvider;

  const OrderReviewModal({
    super.key,
    required this.address,
    required this.delivery,
    required this.payment,
    required this.cartProvider,
    required this.authProvider,
  });

  @override
  State<OrderReviewModal> createState() => _OrderReviewModalState();
}

class _OrderReviewModalState extends State<OrderReviewModal> {
  bool _isLoading = false;

  Future<void> _createSale() async {
    setState(() => _isLoading = true);
    final saleCode = DateTime.now().millisecondsSinceEpoch;
    final result = await widget.cartProvider.createSale(
      widget.authProvider.token!,
      saleCode,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido realizado com sucesso!")),
      );
      Navigator.popUntil(context, ModalRoute.withName('/menuClient'));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: ${result['error']}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cartProvider.totalPrice.toStringAsFixed(2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drag_handle, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "Revisar Pedido",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Endereço
          _infoRow(
            icon: Icons.location_on,
            title: "Endereço de Entrega",
            subtitle: widget.address,
            iconColor: Colors.redAccent,
          ),

          const SizedBox(height: 12),

          // Entrega
          _infoRow(
            icon: Icons.delivery_dining,
            title: "Tipo de Entrega",
            subtitle: widget.delivery,
            iconColor: Colors.redAccent,
          ),

          const SizedBox(height: 12),

          // Pagamento
          _infoRow(
            icon: FontAwesomeIcons.moneyBillWave,
            title: "Forma de Pagamento",
            subtitle: widget.payment,
            iconColor: Colors.redAccent,
          ),

          const Divider(height: 30),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "R\$ $total",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          //Botões
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit, color: Colors.redAccent),
                  label: const Text(
                    "Alterar Pedido",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createSale,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text("Fazer Pedido"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
