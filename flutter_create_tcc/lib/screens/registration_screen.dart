import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem.")),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {}); // força rebuild visual

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

      // Redireciona direto para o menu do cliente
      Navigator.pushReplacementNamed(context, '/menuClient');
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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 233, 118, 73), Color(0xFF4F4F4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(27),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Crie sua conta preenchendo os campos abaixo:",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // E-mail
                      TextFormField(
                        controller: _emailController,
                        cursorColor: const Color(0xFFFFA07A),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "E-mail",
                          hintStyle: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Digite um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Telefone
                      TextFormField(
                        controller: _phoneController,
                        cursorColor: const Color(0xFFFFA07A),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "Telefone (DDD + número)",
                          hintStyle: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          final phoneRegex = RegExp(r'^[0-9]+$');
                          if (!phoneRegex.hasMatch(value)) {
                            return 'Digite apenas números';
                          }
                          if (value.length != 11) {
                            return 'O telefone deve ter exatamente 11 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Senha
                      TextFormField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFFFFA07A),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 14,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "Senha",
                          hintStyle: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter no mínimo 6 caracteres';
                          }
                          final numberRegex = RegExp(r'[0-9]');
                          if (!numberRegex.hasMatch(value)) {
                            return 'A senha deve conter pelo menos 1 número';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Confirmar senha
                      TextFormField(
                        controller: _confirmPasswordController,
                        cursorColor: const Color(0xFFFFA07A),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 14,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "Confirme sua senha",
                          hintStyle: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                      const SizedBox(height: 30),

                      // Botão Registrar
                      SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 233, 118, 73),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: const Text(
                                  "Registrar",
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),

                      // Botão voltar
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 0.8),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Já tenho uma conta",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}