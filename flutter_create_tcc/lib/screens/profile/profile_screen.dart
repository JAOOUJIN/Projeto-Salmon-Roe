import 'package:flutter/material.dart';
import '../../widgets/menu_option_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: const Text(
                      "🍣",
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nome ou Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "joao.silva@example.com",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Cliente Salmon Roe",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Lista de opções (Notificações, Dados da conta, Pagamentos e Configurações)
            MenuOption(
              icon: Icons.notifications,
              title: "Notificações",
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            MenuOption(
              icon: Icons.person,
              title: "Dados da conta",
              onTap: () {
                Navigator.pushNamed(context, '/accountData');
              },
            ),
            MenuOption(
              icon: Icons.credit_card,
              title: "Pagamentos",
              onTap: () {
                Navigator.pushNamed(context, '/payments');
              },
            ),
            MenuOption(
              icon: Icons.settings,
              title: "Configurações",
              onTap: () {
                Navigator.pushNamed(context, '/configuration');
              },
            ),
          ],
        ),
      ),
    )
    );
  }
}