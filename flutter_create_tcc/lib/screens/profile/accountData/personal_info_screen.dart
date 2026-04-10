import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../widgets/profile/app_mask.dart';
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
  final _cpfFormatter = AppMasks.cpfMask;

  bool _isLoading = false;
  bool _cpfLocked = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Preenche os campos com os dados atuais
    _nameController.text = user?.name ?? '';
    if (user?.cpf != null && user!.cpf!.isNotEmpty) {
      _cpfController.text = _cpfFormatter.maskText(user.cpf!);
    }
    _cpfLocked = _cpfController.text.isNotEmpty;
  }

  // Função para salvar as alterações
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isLoading = true);

    final String? cpfToSend =
        !_cpfLocked && _cpfController.text.trim().isNotEmpty
        ? _cpfFormatter.getUnmaskedText()
        : null;

    final result = await authProvider.updateUserData(
      name: _nameController.text.trim(),
      cpf: cpfToSend,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      if (cpfToSend != null) {
        setState(() => _cpfLocked = true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informações atualizadas com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Erro ao atualizar informações.'),
          backgroundColor: Colors.redAccent,
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
                readOnly: _cpfLocked,
                inputFormatters: [_cpfFormatter],
                decoration: InputDecoration(
                  labelText: 'CPF',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  suffixIcon: _cpfLocked
                      ? const Icon(Icons.lock_outline, color: Colors.grey)
                      : null,

                  filled: true,
                  fillColor: _cpfLocked
                      ? Colors.grey.withValues(alpha: 0.08)
                      : Colors.white,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _cpfLocked
                          ? Colors.grey.shade300
                          : Colors.grey.shade400,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _cpfLocked ? Colors.grey : const Color(0xFFFF4C4C),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_cpfLocked) return null;
                  if (value == null || value.isEmpty) return null;

                  if (!AppMasks.isValidCPF(value)) {
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
