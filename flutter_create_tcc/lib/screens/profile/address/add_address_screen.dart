import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/address/address_form.dart';

//

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 1,
        title: const Text(
          'Adicionar Endereço',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AddressForm(
          onSubmit: (data) async {
            final result = await auth.addAddress(
              street: data['street']!,
              number: data['number']!,
              city: data['city']!,
              state: data['state']!,
              zip: data['cep']!,
              neighborhood: data['neighborhood']!,
              complement: data['complement'],
            );

            if (result['success']) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Endereço adicionado com sucesso!'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
                Navigator.of(context).pop(true);
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['error'] ?? 'Erro ao salvar endereço.',
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
