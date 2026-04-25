import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/cart_provider.dart';
import '../profile/profile_menu_item.dart';

/// Tela do perfil para usuário logado
class LoggedInView extends StatelessWidget {
  const LoggedInView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user?.toJson();

    const accentColor = Colors.redAccent;
    const backgroundColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header com avatar e dados do usuário
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child: const Text("🍣", style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name'] ?? user?['email'] ?? 'Usuário',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Cliente Salmon Roe",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Opções do menu
              ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: "Notificações",
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE0E0E0),
              ),

              ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                title: "Dados da conta",
                onTap: () => Navigator.pushNamed(context, '/accountData'),
              ),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE0E0E0),
              ),

              ProfileMenuItem(
                icon: Icons.history_rounded,
                title: "Histórico de Pedidos",
                onTap: () => Navigator.pushNamed(context, '/clientOrders'),
              ),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE0E0E0),
              ),

              ProfileMenuItem(
                icon: Icons.location_on_outlined,
                title: "Endereços",
                onTap: () => Navigator.pushNamed(context, '/addresses'),
              ),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE0E0E0),
              ),

              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: "Configurações",
                onTap: () => Navigator.pushNamed(context, '/configuration'),
              ),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE0E0E0),
              ),

              const SizedBox(height: 24),

              // Botão de logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    final ordersProvider = Provider.of<OrdersProvider>(
                      context,
                      listen: false,
                    );
                    final notificationProvider =
                        Provider.of<NotificationProvider>(
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
                    await authProvider.logout(
                      ordersProvider,
                      notificationProvider,
                      cartProvider,
                      addressProvider,
                    );
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/menuClient');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Sair da conta",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
