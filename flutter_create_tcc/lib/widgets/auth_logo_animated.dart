import 'package:flutter/material.dart';

class AuthLogoAnimated extends StatefulWidget {
  final String imagePath;
  final double size;

  const AuthLogoAnimated({
    super.key,
    required this.imagePath,
    this.size = 200,
  });

  @override
  State<AuthLogoAnimated> createState() => _AuthLogoAnimatedState();
}

class _AuthLogoAnimatedState extends State<AuthLogoAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatX;
  late Animation<double> _floatY;

  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatX = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _opacity = 1.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_floatX.value, _floatY.value),
            child: Image.asset(
              widget.imagePath,
              width: widget.size,
              height: widget.size,
            ),
          );
        },
      ),
    );
  }
}
