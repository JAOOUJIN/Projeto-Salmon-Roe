import 'package:flutter/material.dart';

class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key});

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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.redAccent),
          ),
          child: const ListTile(
            leading: Icon(Icons.payments_outlined, color: Colors.redAccent),
            title: Text("Pagar quando chegar"),
            subtitle: Text("Pagamento na entrega"),
          ),
        ),
      ],
    );
  }
}
