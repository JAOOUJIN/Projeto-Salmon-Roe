import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/otp_input_fields.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Lista de controllers para os 6 dígitos do código
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Timer do Reenvio
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _verifyCodeAndResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Junta os 6 dígitos em uma única String de código
    final code = _codeControllers.map((c) => c.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Digite o código de 6 dígitos'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final provider = context.read<AuthProvider>();

    // Chama o resetPassword passando o 'code' (antigo OTP)
    final result = await provider.resetPassword(
      widget.email,
      code,
      _passwordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Senha redefinida com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Erro ao redefinir senha'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    final provider = context.read<AuthProvider>();
    final result = await provider.resendOtp(widget.email);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _secondsRemaining = 60;
        _canResend = false;
      });

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Novo código enviado para seu email."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Erro ao reenviar código'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Ícone de segurança
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4C4C).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  size: 32,
                  color: Color(0xFFFF4C4C),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Verificar Código",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                widget.email,
                style: const TextStyle(
                  color: Color(0xFFFF4C4C),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Digite o código enviado para seu email\n e crie uma nova senha",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// INPUT DOS 6 DÍGITOS DO CÓDIGO
              OtpInputFields(controllers: _codeControllers),

              const SizedBox(height: 32),

              /// FORMULÁRIO DE NOVA SENHA
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Nova senha",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFFF4C4C),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(color: Color(0xFFFF4C4C), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Digite sua nova senha";
                  }
                  if (value.length < 6) {
                    return "Mínimo de 6 caracteres";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirmar senha",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFFF4C4C),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(color: Color(0xFFFF4C4C), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirme sua senha";
                  }
                  if (value != _passwordController.text) {
                    return "As senhas não coincidem";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              /// BOTÃO DE AÇÃO
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyCodeAndResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4C4C),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_reset),
                            SizedBox(width: 8),
                            Text(
                              "Redefinir senha",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              /// RODAPÉ: REENVIAR E VOLTAR
              _canResend
                  ? TextButton(
                      onPressed: _resendCode,
                      child: const Text(
                        "Reenviar código",
                        style: TextStyle(color: Color(0xFFFF4C4C)),
                      ),
                    )
                  : Text("Reenviar código em ${_secondsRemaining}s"),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Voltar",
                  style: TextStyle(color: Color(0xFFFF4C4C)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
