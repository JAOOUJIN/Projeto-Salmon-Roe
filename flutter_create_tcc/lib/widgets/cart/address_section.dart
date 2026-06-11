import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/models/address_model.dart';
import '../../screens/profile/address/address_screen.dart';

class AddressSection extends StatelessWidget {
  final AddressModel selectedAddress;
  final ValueChanged<AddressModel> onAddressChanged;

  const AddressSection({
    super.key,
    required this.selectedAddress,
    required this.onAddressChanged,
  });

  Future<void> _openAddressScreen(BuildContext context) async {
    final result = await showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: const AddressScreen(),
        ),
      ),
    );

    if (result != null) {
      onAddressChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Entregar no endereço",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => _openAddressScreen(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4C4C),
                ),
                child: const Text("Trocar"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${selectedAddress.street}, ${selectedAddress.number}", 
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
