import 'package:flutter/material.dart';
import '../profile/address/address_screen.dart';

class ConfirmAddressScreen extends StatefulWidget {
  final String initialAddress;

  const ConfirmAddressScreen({super.key, required this.initialAddress});

  @override
  State<ConfirmAddressScreen> createState() => _ConfirmAddressScreenState();
}

class _ConfirmAddressScreenState extends State<ConfirmAddressScreen> {
  late String selectedAddress;
  String selectedDelivery = "Padrão"; // Só uma opção por enquanto

  @override
  void initState() {
    super.initState();
    selectedAddress = widget.initialAddress;
  }

  Future<void> _openAddressScreen() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          child: const AddressScreen(),
        ),
      ),
    );

    if (result != null) {
      final street = result["street"] ?? "";
      final number = result["number"] ?? "";
      setState(() {
        selectedAddress = "$street, $number";
      });
    }
  }

  void _continueToReview() {
    Navigator.pop(context, {
      'address': selectedAddress,
      'delivery': selectedDelivery,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Endereço")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do endereço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Entregar no endereço",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: _openAddressScreen,
                  child: const Text(
                    "Trocar",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(selectedAddress, style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 24),

            const Text(
              "Opções de entrega",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: ListTile(
                title: const Text("Padrão"),
                subtitle: const Text("Hoje, 19 - 29 min"),
                trailing: const Text(
                  "Grátis",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Botão Continuar
            ElevatedButton(
              onPressed: _continueToReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Continuar",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
