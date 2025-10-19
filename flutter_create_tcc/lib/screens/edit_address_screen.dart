import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/address_form.dart';

class EditAddressScreen extends StatelessWidget {
  final AddressModel address;

  const EditAddressScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 1,
        title: const Text(
          'Editar Endereço',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AddressForm(
          isEditing: true,
          initialData: {
            'cep': address.zip,
            'street': address.street,
            'neighborhood': address.neighborhood,
            'city': address.city,
            'state': address.state,
            'number': address.number,
            'complement': address.complement,
          },
          onSubmit: (data) async {
            final result = await auth.updateAddress(
              addressId: address.id,
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
                    content: Text('Endereço atualizado com sucesso!'),
                  ),
                );
                Navigator.of(context).pop(true);
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['error'] ?? 'Erro ao atualizar endereço.',
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
