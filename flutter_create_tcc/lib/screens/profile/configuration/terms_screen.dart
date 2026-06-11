import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFFF4C4C);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Termos de Uso",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/logo2.png', height: 80),
                  const SizedBox(height: 15),
                  const Text(
                    "Termos e Condições",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: brandRed,
                    ),
                  ),
                  const Text(
                    "Regras de utilização do serviço",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTermSection(
                    icon: Icons.person_add_alt_1,
                    title: "1. Cadastro e Responsabilidade",
                    content:
                        "Ao criar uma conta, você se compromete a fornecer informações verídicas. O uso da conta é pessoal e intransferível.",
                  ),
                  _buildTermSection(
                    icon: Icons.shopping_bag,
                    title: "2. Pedidos e Cancelamento",
                    content:
                        "Pedidos via Pix devem ser pagos em até 10 minutos. Após esse prazo, o sistema realizará o cancelamento automático por falta de pagamento.",
                  ),
                  _buildTermSection(
                    icon: Icons.access_time_filled,
                    title: "3. Horário de Funcionamento",
                    content:
                        "As entregas estão sujeitas ao horário de operação do restaurante e à disponibilidade de entregadores na sua região.",
                  ),
                  _buildTermSection(
                    icon: Icons.gavel,
                    title: "4. Conduta Ética",
                    content:
                        "É estritamente proibido o uso do aplicativo para trotes ou tentativas de fraude. Tais ações resultarão no banimento imediato da conta.",
                  ),
                  _buildTermSection(
                    icon: Icons.school,
                    title: "5. Natureza do Projeto",
                    content:
                        "O Salmon Roe é um projeto acadêmico desenvolvido para fins de conclusão de curso (TCC). Os dados e operações aqui realizados seguem propósitos educacionais.",
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Última atualização: Maio de 2026",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF4C4C), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
