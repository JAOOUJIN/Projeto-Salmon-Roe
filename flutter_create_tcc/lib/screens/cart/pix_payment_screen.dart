import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';

class PixPaymentScreen extends StatefulWidget {
  const PixPaymentScreen({super.key});

  @override
  State<PixPaymentScreen> createState() => _PixPaymentScreenState();
}

class _PixPaymentScreenState extends State<PixPaymentScreen> {
  String? _pixCode;
  Timer? _timer;
  int _secondsRemaining = 600;
  bool _hasCheckedStatus = false; 

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        _showTimeoutAlert(); 
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  // Pop-up de Sucesso se o cliente pagou
  void _showSuccessAnimation() {
    _timer?.cancel();
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

  // Pop-up de Tempo Expirado se o Go cancelou no servidor
  void _showTimeoutAlert() {
    _timer?.cancel();
    context.read<AuthProvider>().clearLastConfirmedSale();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off, color: Colors.orange, size: 80),
              SizedBox(height: 20),
              Text(
                "Tempo Limite Atingido",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "O código Pix expirou e o pedido foi cancelado automaticamente pelo servidor.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName('/menuClient'));
      }
    });
  }

  void _verifyOrderActualStatus(String saleId) async {
    if (_hasCheckedStatus) return;
    _hasCheckedStatus = true;

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final ordersProv = context.read<OrdersProvider>();
    await ordersProv.fetchOrders(token);

    final actualOrder = ordersProv.orders.firstWhere(
      (o) => o.saleCode.toString() == saleId,
      orElse: () => ordersProv.orders.first,
    );

    if (actualOrder.status == 'cancelled' ||
        actualOrder.status == 'cancelled_by_timeout') {
      _showTimeoutAlert();
    } else {
      _showSuccessAnimation();
    }
  }

  void _copyToClipboard() {
    if (_pixCode == null) return;
    Clipboard.setData(ClipboardData(text: _pixCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Código Pix copiado!"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final auth = context.watch<AuthProvider>();
    final pixData = args['pix_data'];

    _pixCode = pixData['qr_code'] ?? "Código não disponível";
    final String? qrCodeUrl = pixData['qr_code_base64'];
    final currentSaleId = pixData['sale']?['_id']?.toString();
    final double totalPrice = args['total_price'] ?? 0.0;

    if (auth.lastConfirmedSaleId != null &&
        auth.lastConfirmedSaleId == currentSaleId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyOrderActualStatus(
          currentSaleId!,
        ); 
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
            const Icon(Icons.pix, size: 40, color: Color(0xFF32BCAD)),
            const SizedBox(height: 16),
            const Text(
              "Aguardando pagamento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Total a pagar: R\$ ${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFFFF4C4C),
              ),
            ),
            const SizedBox(height: 24),

            if (qrCodeUrl != null && qrCodeUrl.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.network(
                  qrCodeUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 200,
                      width: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF32BCAD),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.qr_code_2,
                    size: 200,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFFFF4C4C),
                ),
                const SizedBox(width: 8),
                Text(
                  "Expira em: ${_formatTime(_secondsRemaining)}",
                  style: const TextStyle(
                    color: Color(0xFFFF4C4C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_pixCode != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFFFF4C4C)),
                      onPressed: _copyToClipboard,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            SizedBox(
              width: 240,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                label: const Text(
                  "COPIAR CÓDIGO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4C4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
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
