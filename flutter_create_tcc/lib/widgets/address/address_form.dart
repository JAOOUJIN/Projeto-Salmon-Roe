import 'package:flutter/material.dart';
import '../../services/via_cep_services.dart';

class AddressForm extends StatefulWidget {
  final Future<void> Function(Map<String, String?> data) onSubmit;
  final Map<String, String?>? initialData;
  final bool isEditing;

  const AddressForm({
    super.key,
    required this.onSubmit,
    this.initialData,
    this.isEditing = false,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  bool _isLoadingCep = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _cepController.text = widget.initialData!['cep'] ?? '';
      _streetController.text = widget.initialData!['street'] ?? '';
      _neighborhoodController.text = widget.initialData!['neighborhood'] ?? '';
      _cityController.text = widget.initialData!['city'] ?? '';
      _stateController.text = widget.initialData!['state'] ?? '';
      _numberController.text = widget.initialData!['number'] ?? '';
      _complementController.text = widget.initialData!['complement'] ?? '';
    }
  }

  Future<void> _buscarEnderecoPorCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um CEP válido.')));
      return;
    }

    setState(() => _isLoadingCep = true);
    final viaCep = ViaCepService();
    final result = await viaCep.buscarEnderecoPorCep(cep);

    if (!mounted) return;
    setState(() => _isLoadingCep = false);

    if (result['success']) {
      final data = result['data'];
      _streetController.text = data['logradouro'] ?? '';
      _neighborhoodController.text = data['bairro'] ?? '';
      _cityController.text = data['localidade'] ?? '';
      _stateController.text = data['uf'] ?? '';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Erro ao buscar CEP.')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final formData = {
      'cep': _cepController.text,
      'street': _streetController.text,
      'number': _numberController.text,
      'neighborhood': _neighborhoodController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'complement': _complementController.text.isNotEmpty
          ? _complementController.text
          : null,
    };

    await widget.onSubmit(formData);
    if (mounted) setState(() => _isSubmitting = false);
  }

  InputDecoration _inputDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _cepController,
            decoration: _inputDecoration(
              'CEP',
              suffix: _isLoadingCep
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _buscarEnderecoPorCep,
                    ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'CEP obrigatório' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _streetController,
            decoration: _inputDecoration('Rua'),
            validator: (v) => v!.isEmpty ? 'Rua obrigatória' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _numberController,
            decoration: _inputDecoration('Número'),
            validator: (v) => v!.isEmpty ? 'Número obrigatório' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _neighborhoodController,
            decoration: _inputDecoration('Bairro'),
            validator: (v) => v!.isEmpty ? 'Bairro obrigatório' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cityController,
            decoration: _inputDecoration('Cidade'),
            validator: (v) => v!.isEmpty ? 'Cidade obrigatória' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _stateController,
            decoration: _inputDecoration('Estado'),
            validator: (v) => v!.isEmpty ? 'Estado obrigatório' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _complementController,
            decoration: _inputDecoration('Complemento (opcional)'),
          ),
          const SizedBox(height: 25),
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _handleSubmit,
                  child: Text(
                    isEditing ? 'Salvar Alterações' : 'Salvar Endereço',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}
