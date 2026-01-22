import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/address_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../widgets/address/address_form.dart';

class EditAddressScreen extends StatelessWidget {
  final AddressModel address;

  const EditAddressScreen({super.key, required this.address});

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
            try {
              await addressProvider.updateAddress(
                token: context.read<AuthProvider>().token!,
                addressId: address.id,
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
                    content: Text('Endereço atualizado com sucesso!'),
                  ),
                );
                Navigator.of(context).pop(true);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao atualizar endereço.')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
