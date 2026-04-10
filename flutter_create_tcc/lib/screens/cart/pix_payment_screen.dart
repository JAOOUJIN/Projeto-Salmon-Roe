import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Importe seus caminhos corretos aqui
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';

class PixPaymentScreen extends StatefulWidget {
  const PixPaymentScreen({super.key});

  @override
  State<PixPaymentScreen> createState() => _PixPaymentScreenState();
}

class _PixPaymentScreenState extends State<PixPaymentScreen> {
  // O pixCode virá do resultado da chamada da API (CartProvider.createSale)
  String? _pixCode;
  bool _isOrderCreated = false;

  Timer? _timer;
  int _secondsRemaining = 600; // 10 minutos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPixOrder();
    });
  }

  // Função que chama o backend para gerar o código Pix
  Future<void> _processPixOrder() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();

    // Simulando o código da venda (Time-based)
    final saleCode = DateTime.now().millisecondsSinceEpoch;

    final result = await cart.createSale(
      auth.token!,
      saleCode,
      address: args['address'].toString(),
      delivery: args['delivery'],
      payment: "Pix",
    );

    if (result['success'] == true) {
      setState(() {
        // O backend deve retornar o código Pix no campo 'pix_copia_e_cola' 
        _pixCode =
            result['data']['pix_copia_e_cola'] ??
            "00020101021226850014br.gov.bcb.pix...";
        _isOrderCreated = true;
      });
      _startTimer();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao gerar Pix: ${result['error']}")),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _copyToClipboard() {
    if (_pixCode == null) return;
    Clipboard.setData(ClipboardData(text: _pixCode!));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Código Pix copiado!")));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "PAGAMENTO PIX",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () =>
              Navigator.popUntil(context, ModalRoute.withName('/menuClient')),
        ),
      ),
      body: !_isOrderCreated
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4C4C)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // QR CODE PLACEHOLDER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.qr_code_2,
                          size: 200,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total a pagar: R\$ ${cart.totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Aguardando pagamento",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Utilize o QR Code acima ou o código abaixo para pagar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  // Timer regressivo
                  Text(
                    "Expira em: ${_formatTime(_secondsRemaining)}",
                    style: const TextStyle(
                      color: Color(0xFFFF4C4C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bloco Copia e Cola
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pix,
                          color: Color(0xFF32BCAD),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _pixCode!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.grey),
                          onPressed: _copyToClipboard,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botão de Finalizar
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _copyToClipboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4C4C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "COPIAR CÓDIGO PIX",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
