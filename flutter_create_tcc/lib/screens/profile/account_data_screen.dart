import 'package:flutter/material.dart';

class AccountDataScreen extends StatelessWidget {
  const AccountDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dados da Conta"),
      ),
      body: const Center(
        child: Text("Conteúdo da tela de dados da conta"),
      ),
    );
  }
}
