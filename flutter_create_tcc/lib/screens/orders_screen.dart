import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos do Cliente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Pedido 1: Sushi de Salmão - Status: Entregue'),
            Text('Pedido 2: Temaki de Atum - Status: Em preparo'),
          ],
        ),
      ),
    );
  }
}