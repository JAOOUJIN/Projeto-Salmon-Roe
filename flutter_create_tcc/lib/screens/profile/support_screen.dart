import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  final String? orderCode; 

  const SupportScreen({super.key, this.orderCode});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int _start = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        _launchWhatsApp();
      } else {
        setState(() => _start--);
      }
    });
  }

  Future<void> _launchWhatsApp() async {
    const String phoneNumber = "5511996679717";

    String message = "Olá! Gostaria de suporte.";
    if (widget.orderCode != null) {
      message =
          "Olá! Preciso de ajuda com o meu pedido #${widget.orderCode} no Salmon Roe.";
    } else {
      message = "Olá! Gostaria de tirar uma dúvida sobre o Salmon Roe.";
    }

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao abrir o WhatsApp.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.headset_mic_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              "Suporte Salmon Roe",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (widget.orderCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Referente ao pedido #${widget.orderCode}",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 40),

            // TIMER 
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: _start / 5),
                    duration: const Duration(
                      milliseconds: 900,
                    ), // Suaviza a transição
                    builder: (context, value, child) =>
                        CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          color: Colors.redAccent,
                          backgroundColor: Colors.grey[100],
                        ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    "$_start",
                    key: ValueKey<int>(_start),
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            TextButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context);
              },
              child: const Text(
                "CANCELAR",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
