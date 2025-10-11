import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../providers/auth_provider.dart';
import '../screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      authProvider.isLoading; 
    });

    try {
      final result = await authProvider.login(
        _loginIdController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login realizado com sucesso!")),
        );

        //Redireciona para o menu do cliente
        Navigator.pushReplacementNamed(context, '/menuClient');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? "Erro no login.")),
        );
      }
    } on DioException catch (e) {
      Logger().e('Erro no Login: ${e.response?.data}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro no Login: Credenciais inválidas.')),
      );
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(27),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 247, 121, 71),
              Color.fromARGB(255, 79, 79, 79),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Digite os dados de acesso abaixo:",
                style: TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Campo Login (E-mail ou Telefone)
              TextFormField(
                controller: _loginIdController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: const Color(0xFFFFA07A),
                style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: "Digite o seu e-mail ou telefone",
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
                  final phoneRegex = RegExp(r'^[0-9]{11}$');

                  if (!emailRegex.hasMatch(value) &&
                      !phoneRegex.hasMatch(value)) {
                    return 'Digite um e-mail válido ou um telefone com 11 dígitos';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Campo Senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: const Color(0xFFFFA07A),
                style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: "Digite sua senha",
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
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botão Acessar
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 233, 118, 73),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(17),
                          backgroundColor:
                              const Color.fromARGB(255, 233, 118, 73),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: const Text(
                          "Acessar",
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),

              // Botão Criar Conta
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30, width: 0.8),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Crie sua conta",
                    style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}