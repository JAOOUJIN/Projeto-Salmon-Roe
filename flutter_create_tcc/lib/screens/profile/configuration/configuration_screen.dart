import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/orders_provider.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CONFIGURAÇÕES",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // GERENCIAR NOTIFICAÇÕES
          _buildOption(
            context,
            title: "Gerenciar notificações",
            onTap: () => Navigator.pushNamed(context, '/manageNotifications'),
          ),
          const Divider(height: 1, thickness: 1, color: dividerColor),

          // SOBRE ESTA VERSÃO
          _buildOption(
            context,
            title: "Sobre esta versão",
            onTap: () => Navigator.pushNamed(context, '/aboutVersion'),
          ),
          const Divider(height: 1, thickness: 1, color: dividerColor),

          //SAIR DA CONTA
          _buildOption(
            context,
            title: "Sair",
            showArrow: false,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: showArrow
          ? const Icon(Icons.chevron_right, color: Colors.grey, size: 20)
          : null,
      onTap: onTap,
    );
  }

  // Confirmação de Logout
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair da conta?"),
        content: const Text(
          "Suas informações e carrinho serão limpos deste dispositivo.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final ordersProvider = Provider.of<OrdersProvider>(
                context,
                listen: false,
              );
              final notificationProvider = Provider.of<NotificationProvider>(
                context,
                listen: false,
              );
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              final addressProvider = Provider.of<AddressProvider>(
                context,
                listen: false,
              );

              // Chama o logout que limpa todos os providers
              await authProvider.logout(
                ordersProvider,
                notificationProvider,
                cartProvider,
                addressProvider,
              );

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/menuClient',
                  (route) => false,
                );
              }
            },
            child: const Text(
              "SAIR",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
