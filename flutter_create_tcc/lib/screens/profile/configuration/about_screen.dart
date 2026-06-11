import 'package:flutter/material.dart';

class AboutVersionScreen extends StatelessWidget {
  const AboutVersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "SOBRE ESTA VERSÃO",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailOption(
            context,
            title: "Termos de uso",
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
          const Divider(height: 1, thickness: 1, color: dividerColor),

          _buildDetailOption(
            context,
            title: "Política de Privacidade",
            onTap: () {
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          const Divider(height: 1, thickness: 1, color: dividerColor),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Versão 1.0.0 (Lançamento)",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailOption(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
