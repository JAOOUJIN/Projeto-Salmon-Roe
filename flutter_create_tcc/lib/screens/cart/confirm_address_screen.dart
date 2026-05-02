import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/cart/address_section.dart';
import '../../widgets/cart/delivery_options_section.dart';
import 'review_order_screen.dart';

class ConfirmAddressScreen extends StatelessWidget {
  const ConfirmAddressScreen({super.key});

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
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          final selectedAddress = provider.selectedAddress;

          if (selectedAddress == null) {
            return const Center(
              child: Text("Nenhum endereço selecionado. Volte e selecione um."),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Padding(
              key: ValueKey(selectedAddress.id),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddressSection(
                    selectedAddress: selectedAddress,
                    onAddressChanged: (_) {},
                  ),
                  const SizedBox(height: 24),
                  const DeliveryOptionsSection(),
                  const Spacer(),
                  SafeArea(
                    top: false,
                    child: Container(
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
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => FractionallySizedBox(
                              heightFactor: 0.95,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                                // Adicionado SafeArea interno para o ReviewOrderScreen
                                child: SafeArea(
                                  child: ReviewOrderScreen(
                                    address: selectedAddress,
                                    delivery: "Padrão",
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
