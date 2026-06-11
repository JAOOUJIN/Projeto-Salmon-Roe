import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fundo gradiente cobrindo toda a tela
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.35,
              colors: [Color(0xFF2D1F1D), Color(0xFF121212)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        // Textura seigaiha cobrindo toda a tela
        Positioned.fill(
          child: Opacity(
            opacity: 0.09,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/seigaiha.png'),
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.none,
                  scale: 2.0,
                ),
              ),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
