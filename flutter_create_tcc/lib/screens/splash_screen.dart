import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    // Simula uma espera para carregar recursos
    await Future.delayed(const Duration(seconds: 5));

    final success = await auth.tryAutoLogin(notificationProvider);

    if (!mounted) return;

    // Se logado ou não, vai pro menu do cliente
    if (success) {
      Navigator.pushReplacementNamed(context, '/menuClient');
    } else {
      Navigator.pushReplacementNamed(context, '/menuClient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Salmon Roe',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE15B1D),
          ),
        ),
      ),
    );
  }
}
