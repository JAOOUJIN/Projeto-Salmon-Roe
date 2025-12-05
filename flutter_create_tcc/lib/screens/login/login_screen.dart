import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_background.dart';
import 'registration_screen.dart';
import '../../widgets/auth/auth_logo_animated.dart';

// Tela de Login
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

  // Função para realizar o login
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
          const SnackBar(
            content: Text("Login realizado com sucesso!"),
            duration: Duration(milliseconds: 500),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/menuClient',
          (route) => false,
        );
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  const AuthLogoAnimated(
                    imagePath: 'assets/images/logo.png',
                    size: 240,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Acesse sua conta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 25),
                  // Inputs
                  AuthTextField(
                    controller: _loginIdController,
                    label: "E-mail ou Telefone",
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  AuthTextField(
                    controller: _passwordController,
                    label: "Senha",
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/forgetPassword'),
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTÃO ENTRAR
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
                            onPressed: _login,
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login,
                                  color: Colors.black87,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Entrar",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 15),

                  // BOTÃO CRIAR CONTA
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationScreen(),
                          ),
                        );
                      },
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
                        "Crie sua conta",
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
