import 'package:flutter/material.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Home'),
      ),
      body: Center(
        child: const Text('Client Home Screen'),
      ),
    );
  }
}
