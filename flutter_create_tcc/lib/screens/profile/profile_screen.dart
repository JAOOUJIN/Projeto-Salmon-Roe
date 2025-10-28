import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile/logged_in_view.dart';
import '../../widgets/profile/logged_out_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Mostra loading enquanto verifica autenticação
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.orangeAccent),
        ),
      );
    }

    // Decide qual view mostrar
    return authProvider.isAuthenticated
        ? const LoggedInView()
        : const LoggedOutView();
  }
}
