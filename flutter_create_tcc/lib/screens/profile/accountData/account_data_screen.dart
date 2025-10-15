import 'package:flutter/material.dart';

class AccountDataScreen extends StatelessWidget {
  const AccountDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados da Conta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Informações pessoais'),
            subtitle: const Text('Preencha seu nome completo e CPF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/personalInfo'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Informações de acesso'),
            subtitle: const Text('Cadastre os dados de acesso de forma segura'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/accessInfo'),
          ),
        ],
      ),
    );
  }
}
