import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../widgets/address/address_card.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token!;
      context.read<AddressProvider>().fetchAddresses(token);
    });
  }

  Future<void> _navigateToAddAddress() async {
    final added = await Navigator.pushNamed(context, '/addAddress');

    if (added == true && mounted) {
      final token = context.read<AuthProvider>().token!;
      await context.read<AddressProvider>().fetchAddresses(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Endereço de Entrega',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _navigateToAddAddress,
        child: const Icon(Icons.add_rounded, color: Colors.black87, size: 30),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.addresses.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum endereço cadastrado ainda.",
                style: TextStyle(
                  color: Color.fromARGB(137, 10, 7, 7),
                  fontSize: 16,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final token = context.read<AuthProvider>().token!;
              await provider.fetchAddresses(token);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                // Buscar endereço (visual apenas por enquanto)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const ListTile(
                    leading: Icon(Icons.search, color: Colors.grey),
                    title: Text(
                      "Buscar endereço e número",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ),

                // 📍 Usar localização
                Consumer<AddressProvider>(
                  builder: (context, provider, _) {
                    final isCurrentLocationSelected =
                        provider.selectedAddress != null &&
                        provider.selectedAddress!.id.startsWith(
                          'current_location_',
                        );

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: provider.isLoading
                          ? null
                          : () async {
                              try {
                                await provider.useCurrentLocation();

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (_) {
                                if (context.mounted &&
                                    provider.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(provider.errorMessage!),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: provider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.redAccent,
                                ),
                          title: const Text(
                            "Usar minha localização",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            provider.isLoading
                                ? "Obtendo localização..."
                                : isCurrentLocationSelected
                                ? "${provider.selectedAddress!.street}, ${provider.selectedAddress!.number}"
                                : "Localização atual",
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                //Lista de endereços
                ...List.generate(provider.addresses.length, (index) {
                  final address = provider.addresses[index];
                  final isSelected = selectedIndex == index;
                  final isDefault = address.id == provider.defaultAddressId;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                      context.read<AddressProvider>().selectAddress(address);
                      Navigator.pop(context);
                    },
                    child: AddressCard(
                      address: address,
                      isSelected: isSelected,
                      isDefault: isDefault,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
