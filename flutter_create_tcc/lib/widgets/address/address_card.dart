import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';

class AddressCard extends StatefulWidget {
  final AddressModel address;
  final bool isSelected;
  final bool isDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.isDefault = false,
  });

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  Future<void> _showOptions() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.star_border_rounded,
                    label: "Definir como principal",
                    onTap: () async {
                      Navigator.pop(context);
                      await _setDefaultAddress();
                    },
                  ),
                  _buildOption(
                    icon: Icons.edit_rounded,
                    label: "Editar",
                    onTap: () {
                      Navigator.pop(context);
                      _editAddress();
                    },
                  ),
                  _buildOption(
                    icon: Icons.delete_outline_rounded,
                    label: "Excluir",
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _deleteAddress();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _setDefaultAddress() async {
    print('🔥 STARTING _setDefaultAddress');
    print('🔥 ADDRESS ID: ${widget.address.id}');
    print('🔥 ADDRESS ID TYPE: ${widget.address.id.runtimeType}');
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );
    try {
      await addressProvider.setDefault(
        context.read<AuthProvider>().token!,
        widget.address.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço definido como padrão!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao definir padrão')));
      }
    }
  }

  Future<void> _editAddress() async {
    print('🔥 STARTING _editAddress');
    print('🔥 ADDRESS: ${widget.address}');
    await Navigator.pushNamed(
      context,
      '/editAddress',
      arguments: widget.address,
    );
  }

  Future<void> _deleteAddress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Endereço'),
        content: const Text('Tem certeza que deseja excluir este endereço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );
    try {
      await addressProvider.deleteAddress(
        context.read<AuthProvider>().token!,
        widget.address.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Endereço excluído!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao excluir')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.address;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isSelected
              ? Colors.redAccent
              : Colors.grey.withAlpha((0.2 * 255).toInt()),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withAlpha((0.05 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          ListTile(
            leading: Icon(
              Icons.location_on_rounded,
              color: widget.isSelected
                  ? Colors.redAccent
                  : Colors.redAccent.withAlpha((0.4 * 255).toInt()),
              size: 28,
            ),
            title: Text(
              '${address.street}, ${address.number}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${address.neighborhood} - ${address.city}/${address.state}',
                ),
                if (address.complement != null &&
                    address.complement!.isNotEmpty)
                  Text(address.complement!),
                Text(
                  'CEP: ${address.zip}',
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
              onPressed: _showOptions,
            ),
          ),
          if (widget.isDefault) // Indicador visual
            Positioned(
              right: 10,
              top: 10,
              child: Icon(Icons.star, color: Colors.amber.shade700, size: 22),
            ),
        ],
      ),
    );
  }
}
