import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/models/address_model.dart';
import '../../widgets/cart/address_section.dart';
import '../../widgets/cart/delivery_options_section.dart';

class ConfirmAddressScreen extends StatefulWidget {
  final AddressModel initialAddress;

  const ConfirmAddressScreen({super.key, required this.initialAddress});

  @override
  State<ConfirmAddressScreen> createState() => _ConfirmAddressScreenState();
}

class _ConfirmAddressScreenState extends State<ConfirmAddressScreen> {
  late AddressModel selectedAddress;
  String selectedDelivery = "Padrão";

  @override
  void initState() {
    super.initState();
    selectedAddress = widget.initialAddress;
  }

  void _continue() {
    Navigator.pop(
      context,
      selectedAddress,
    ); // Retorna AddressModel para CartScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Confirmar Endereço",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Padding(
          key: ValueKey(selectedAddress),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddressSection(
                selectedAddress: selectedAddress,
                onAddressChanged: (newAddress) {
                  setState(() {
                    selectedAddress = newAddress;
                  });
                },
              ),
              const SizedBox(height: 24),
              const DeliveryOptionsSection(),
              const Spacer(),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: ElevatedButton(
                  onPressed: _continue,
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
                    "Continuar",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
