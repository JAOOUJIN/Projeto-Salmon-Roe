import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../widgets/address/address_form.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 1,
        title: const Text(
          'Adicionar Endereço',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AddressForm(
          onSubmit: (data) async {
            try {
              await addressProvider.addAddress(
                token: context.read<AuthProvider>().token!,
                street: data['street']!,
                number: data['number']!,
                city: data['city']!,
                state: data['state']!,
                zip: data['cep']!,
                neighborhood: data['neighborhood']!,
                complement: data['complement'],
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Endereço adicionado com sucesso!'),
                  ),
                );
                Navigator.of(context).pop(true);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao salvar endereço.')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
