import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

// Tela para editar informações pessoais: nome e CPF
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  bool _isLoading = false;
  bool _cpfLocked = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Preenche os campos com os dados atuais
    _nameController.text = user?.name ?? '';
    _cpfController.text = user?.cpf ?? '';
    _cpfLocked = _cpfController.text.isNotEmpty;
  }

  bool _isValidCPF(String cpf) {
    // Remove tudo que não for número
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false; // Evita repetidos

    // Validação oficial dos dígitos verificadores
    int calcDigit(String cpf, int length) {
      int sum = 0;
      for (int i = 0; i < length; i++) {
        sum += int.parse(cpf[i]) * (length + 1 - i);
      }
      int mod = sum % 11;
      return mod < 2 ? 0 : 11 - mod;
    }

    int d1 = calcDigit(cpf, 9);
    int d2 = calcDigit(cpf, 10);

    return d1 == int.parse(cpf[9]) && d2 == int.parse(cpf[10]);
  }

  // Função para salvar as alterações
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isLoading = true);

    final result = await authProvider.updateUserData(
      name: _nameController.text.trim(),
      cpf: _cpfLocked ? null : _cpfController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informações atualizadas com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Erro ao atualizar informações.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Construção da interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Informações Pessoais'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NOME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // CPF
              TextFormField(
                controller: _cpfController,
                enabled: !_cpfLocked,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  suffixIcon: _cpfLocked
                      ? const Icon(Icons.lock_outline, color: Colors.grey)
                      : null,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_cpfLocked) return null;
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu CPF.';
                  }
                  if (!_isValidCPF(value.trim())) {
                    return 'CPF inválido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 93, 90),
                        Color.fromARGB(255, 236, 53, 50),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Salvar alterações',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
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
