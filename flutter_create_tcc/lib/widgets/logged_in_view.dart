import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'menu_option_widget.dart';

class LoggedInView extends StatelessWidget {
  const LoggedInView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user?.toJson();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com avatar + nome/email
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color.fromARGB(255, 238, 130, 30),
                      child: const Text("🍣", style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['email'] ?? "Usuário desconhecido",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Cliente Salmon Roe",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Opções do menu
              MenuOption(
                icon: Icons.notifications,
                title: "Notificações",
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              MenuOption(
                icon: Icons.person,
                title: "Dados da conta",
                onTap: () => Navigator.pushNamed(context, '/accountData'),
              ),
              MenuOption(
                icon: Icons.credit_card,
                title: "Pagamentos",
                onTap: () => Navigator.pushNamed(context, '/payments'),
              ),
              MenuOption(
                icon: Icons.history,
                title: "Histórico de Pedidos",
                onTap: () => Navigator.pushNamed(context, '/orderHistory'),
              ),
              MenuOption(
                icon: Icons.location_on,
                title: "Endereços",
                onTap: () => Navigator.pushNamed(context, '/addresses'),
              ),
              MenuOption(
                icon: Icons.settings,
                title: "Configurações",
                onTap: () => Navigator.pushNamed(context, '/configuration'),
              ),
              const SizedBox(height: 20),

              // Botão de logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/menuClient');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Sair da conta"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
