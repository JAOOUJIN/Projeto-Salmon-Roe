import 'package:flutter/material.dart';

class DeliveryOptionsSection extends StatelessWidget {
  const DeliveryOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: const ListTile(
        title: Text("Padrão", style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Hoje, 19 - 29 min"),
        trailing: Text(
          "Grátis",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
