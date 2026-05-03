import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFFF4C4C);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Privacidade", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.8,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/logo2.png', height: 80), 
                  const SizedBox(height: 15),
                  const Text(
                    "Política de Privacidade",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: brandRed),
                  ),
                  const Text("Sua segurança é nossa prioridade", style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    icon: Icons.data_usage,
                    title: "Coleta de Dados",
                    content: "Coletamos seu nome, e-mail, telefone e endereço exclusivamente para gerenciar seus pedidos e garantir a entrega correta.",
                  ),
                  _buildSection(
                    icon: Icons.payment,
                    title: "Pagamentos Seguros",
                    content: "As transações Pix são processadas via Mercado Pago. O Salmon Roe não armazena dados sensíveis de pagamento.",
                  ),
                  _buildSection(
                    icon: Icons.notifications_active,
                    title: "Notificações",
                    content: "Utilizamos o Firebase para enviar alertas em tempo real sobre o status do seu pedido (Em preparo, Saiu para entrega).",
                  ),
                  _buildSection(
                    icon: Icons.shield,
                    title: "Proteção",
                    content: "Seus dados de login são protegidos por criptografia de ponta e nunca serão compartilhados com terceiros.",
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Projeto Acadêmico IFSP - 2026",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF4C4C), size: 24),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          Text(content, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}