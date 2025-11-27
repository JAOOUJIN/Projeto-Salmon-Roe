import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_logo_animated.dart';
import '../../widgets/auth/auth_background.dart';

// Tela de Registro
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Função de registro
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem.")));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {});

    final result = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário registrado com sucesso!")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? "Erro ao registrar.")),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    // Configurações da UI do sistema para transparência
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Configura as barras do sistema para serem transparentes
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(27),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const AuthLogoAnimated(
                    imagePath: 'assets/images/logo.png',
                    size: 240,
                  ),

                  const SizedBox(height: 5),
                  const Text(
                    "Crie sua conta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Email
                  AuthTextField(
                    controller: _emailController,
                    label: "E-mail",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Digite um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Telefone
                  AuthTextField(
                    controller: _phoneController,
                    label: "Telefone (DDD + número)",
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Digite apenas números';
                      }
                      if (value.length != 11) {
                        return 'O telefone deve ter 11 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Senha
                  AuthTextField(
                    controller: _passwordController,
                    label: "Senha",
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'A senha deve conter pelo menos 1 número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Confirmar Senha
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: "Confirme sua senha",
                    icon: Icons.lock_reset,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme sua senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // BOTÃO REGISTRAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF7043),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7043),
                              elevation: 8,
                              shadowColor: const Color(
                                0xFFFF7043,
                              ).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Registrar",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 15),

                  // BOTÃO JÁ TENHO CONTA
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFF7043),
                          width: 1.5,
                        ),
                        backgroundColor: const Color(0xFF252525),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: const Color(0xFFFF7043),
                      ),
                      child: const Text(
                        "Já tenho uma conta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
