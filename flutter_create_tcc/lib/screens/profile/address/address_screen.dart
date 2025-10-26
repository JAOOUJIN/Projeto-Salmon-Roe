import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/address_card.dart';

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
      context.read<AuthProvider>().getAddresses();
    });
  }

  void _navigateToAddAddress() async {
    final added = await Navigator.pushNamed(context, '/addAddress');
    if (added == true && mounted) {
      context.read<AuthProvider>().getAddresses();
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
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = auth.user?.addresses ?? [];
          if (addresses.isEmpty) {
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
            onRefresh: () => auth.getAddresses(),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const ListTile(
                    leading: Icon(
                      Icons.my_location_rounded,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      "Usar minha localização",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text("Localização atual - São Paulo"),
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(addresses.length, (index) {
                  final address = addresses[index];
                  final isSelected = selectedIndex == index;
                  final isDefault = address.id == auth.user?.defaultAddressId;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                      final selected = {
                        "street": address.street,
                        "number": address.number,
                      };
                      Navigator.pop(context, selected);
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
