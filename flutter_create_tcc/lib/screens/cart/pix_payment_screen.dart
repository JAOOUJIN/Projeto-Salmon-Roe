import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 

class PixPaymentScreen extends StatefulWidget {
  const PixPaymentScreen({super.key});

  @override
  State<PixPaymentScreen> createState() => _PixPaymentScreenState();
}

class _PixPaymentScreenState extends State<PixPaymentScreen> {
  String? _pixCode;
  Timer? _timer;
  int _secondsRemaining = 600; 

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  // Função para mostrar o sucesso e redirecionar
  void _showSuccessAnimation() {
    _timer?.cancel(); 

    // Limpa o ID confirmado no provider para não repetir a animação
    context.read<AuthProvider>().clearLastConfirmedSale();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              "Pagamento Confirmado!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Seu pedido já está sendo preparado pelo Salmon Roe.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName('/menuClient'));
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
    // Recebendo os dados passados pelo Modal
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

        print("ARGUMENTOS RECEBIDOS: $args");
        
    final pixData = args['pix_data'];
    final currentSaleId = pixData['saleId']?.toString();
    _pixCode = pixData['pix_copia_e_cola'] ?? "Código não disponível";

    final double totalPrice = args['total_price'] ?? 0.0;

    final auth = context.watch<AuthProvider>();

    // Verifica se o pagamento foi confirmado pelo WebSocket
    if (auth.lastConfirmedSaleId != null &&
        auth.lastConfirmedSaleId == currentSaleId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessAnimation();
      });
    }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.pix, size: 80, color: Color(0xFF32BCAD)),
            const SizedBox(height: 24),

            const Text(
              "Aguardando pagamento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Total a pagar: R\$ ${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 32),

            const Text(
              "Copie o código abaixo e utilize o aplicativo do seu banco para finalizar o pagamento.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            Text(
              "O código expira em: ${_formatTime(_secondsRemaining)}",
              style: const TextStyle(
                color: Color(0xFFFF4C4C),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _pixCode!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

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
            const SizedBox(height: 16),
            const Text(
              "Assim que o pagamento for confirmado, esta tela será atualizada automaticamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
