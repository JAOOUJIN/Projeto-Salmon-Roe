import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SPLASH SCREEN V8 (Mestre) – Trajeto do Laser 100% Ajustado ao Shape Real
// ════════════════════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Fase 0 · O Ghost (Silhueta escura de base)
  late final Animation<double> _ghostA;

  // Fase 1 · O Laser correndo pelas curvas (0% → 75%)
  late final Animation<double> _strokeP;

  // Fase 2 · A Cortina do ShaderMask deslizando diagonalmente (10% → 85%)
  late final Animation<double> _curtainProgress;

  // Fase 3 · Pulso senoidal de Glow final de fechamento (88% → 100%)
  late final Animation<double> _glowP;

  String _targetRoute = '/menuClient';

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 4200),
      vsync: this,
    );

    _ghostA = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.12, curve: Curves.easeOut),
    );

    // O laser corre o trajeto vetorial reparametrizado
    _strokeP = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.02, 0.75, curve: _SmoothCubicEase()),
    );

    // A cortina linear diagonal desliza revelando o bloco inteiro
    _curtainProgress = Tween<double>(begin: -1.2, end: 1.5).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.08, 0.85, curve: Curves.easeInOutCubic),
      ),
    );

    _glowP = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.88, 1.00, curve: Curves.easeInOut),
    );

    _ctrl.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final notifications = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final orders = Provider.of<OrdersProvider>(context, listen: false);
    final address = Provider.of<AddressProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    try {
      final ok = await auth.tryAutoLogin(notifications, orders, cart, address);
      _targetRoute = ok ? '/menuClient' : '/menuClient';
    } catch (e) {
      debugPrint('Splash init error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 4600));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: RouteSettings(name: _targetRoute),
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const imgSize = 300.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final glowAlpha = sin(_glowP.value * pi);

            return SizedBox(
              width: imgSize,
              height: imgSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ──────────────────────────────────────────────────────────
                  // CAMADA 0 · O Ghost Permanente (Sombra base de contraste)
                  // ──────────────────────────────────────────────────────────
                  Opacity(
                    opacity: (_ghostA.value * 0.14).clamp(0.0, 1.0),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.15,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0.08,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0.08,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Image.asset(
                        'assets/images/logo2.png',
                        width: imgSize,
                        height: imgSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────────────────
                  // CAMADA 1 · A Cortina de Revelação Progressiva (Sem buracos!)
                  // ──────────────────────────────────────────────────────────
                  if (_ctrl.value > 0.05)
                    ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          transform: _GradientTranslateTransform(
                            _curtainProgress.value,
                          ),
                          colors: const [
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.48, 1.0],
                        ).createShader(bounds);
                      },
                      child: Image.asset(
                        'assets/images/logo2.png',
                        width: imgSize,
                        height: imgSize,
                        fit: BoxFit.contain,
                      ),
                    ),

                  // ──────────────────────────────────────────────────────────
                  // CAMADA 2 · O Ponto de Energia Vivo (CustomPainter corrigido)
                  // ──────────────────────────────────────────────────────────
                  if (_strokeP.value > 0 && _strokeP.value < 0.99)
                    CustomPaint(
                      size: const Size(imgSize, imgSize),
                      painter: _LaserTrackPainter(
                        strokeProgress: _strokeP.value,
                      ),
                    ),

                  // ──────────────────────────────────────────────────────────
                  // CAMADA 3 · Glow Orgânico Final de Fechamento
                  // ──────────────────────────────────────────────────────────
                  if (glowAlpha > 0) ...[
                    Image.asset(
                      'assets/images/logo2.png',
                      width: imgSize,
                      height: imgSize,
                      fit: BoxFit.contain,
                      color: const Color(
                        0xFFFF9E88,
                      ).withValues(alpha: glowAlpha * 0.35),
                      colorBlendMode: BlendMode.srcATop,
                    ),
                    Image.asset(
                      'assets/images/logo2.png',
                      width: imgSize,
                      height: imgSize,
                      fit: BoxFit.contain,
                      color: const Color(
                        0xFFCC3300,
                      ).withValues(alpha: glowAlpha * 0.15),
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ENGINE DE VETORIZAÇÃO DA FAÍSCA (Caminha nas Curvas Reais da Marca)
// ════════════════════════════════════════════════════════════════════════════

mixin _LogoGeometry {
  static const int samplePoints = 360;

  double _bezierCoord(double p0, double p1, double p2, double p3, double t) {
    final m = 1 - t;
    return m * m * m * p0 +
        3 * m * m * t * p1 +
        3 * m * t * t * p2 +
        t * t * t * p3;
  }

  Offset getPathPoint(double t, Size size) {
    final ox = size.width / 2, oy = size.height / 2;
    final sx = size.width * 0.44, sy = size.height * 0.215;

    // Matriz de curvas corrigida com os novos tensores de expansão do Segmento 3
    final curves = [
      // Seg 0: Ponta direita → Arco superior
      [
        ox + sx,
        oy,
        ox + sx,
        oy - sy * 1.12,
        ox + sx * 0.12,
        oy - sy * 1.52,
        ox - sx * 0.10,
        oy - sy * 0.90,
      ],
      // Seg 1: Arco superior → Ponta esquerda
      [
        ox - sx * 0.10,
        oy - sy * 0.90,
        ox - sx * 0.40,
        oy - sy * 0.28,
        ox - sx,
        oy - sy * 0.07,
        ox - sx,
        oy,
      ],
      // Seg 2: Ponta esquerda → Arco inferior central
      [
        ox - sx,
        oy,
        ox - sx,
        oy + sy * 1.15,
        ox - sx * 0.12,
        oy + sy * 1.55,
        ox + sx * 0.10,
        oy + sy * 0.95,
      ],
      // Seg 3: O Ajuste Mestre — Faz a parábola perfeita por fora da barriga e sobe no fim!
      [
        ox + sx * 0.10, oy + sy * 0.95,
        ox + sx * 0.52,
        oy + sy * 1.18, // Tensor 1: Empurra a faísca para baixo e para fora
        ox + sx * 0.92,
        oy + sy * 0.55, // Tensor 2: Segura a curva aberta antes da subida final
        ox + sx, oy, // Ponto de destino na extremidade direita
      ],
    ];

    final rawT = t * curves.length;
    final idx = rawT.floor().clamp(0, curves.length - 1);
    final localT = rawT - idx;
    final c = curves[idx];

    return Offset(
      _bezierCoord(c[0], c[2], c[4], c[6], localT),
      _bezierCoord(c[1], c[3], c[5], c[7], localT),
    );
  }

  List<double> buildArcLengths(Size size) {
    final lens = List<double>.filled(_LogoGeometry.samplePoints + 1, 0);
    Offset prev = getPathPoint(0, size);
    for (int i = 1; i <= _LogoGeometry.samplePoints; i++) {
      final cur = getPathPoint(i / _LogoGeometry.samplePoints, size);
      final dx = cur.dx - prev.dx, dy = cur.dy - prev.dy;
      lens[i] = lens[i - 1] + sqrt(dx * dx + dy * dy);
      prev = cur;
    }
    return lens;
  }

  int getArcIndex(List<double> lens, double target) {
    int lo = 0, hi = _LogoGeometry.samplePoints;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (lens[mid] < target)
        lo = mid + 1;
      else
        hi = mid;
    }
    return lo.clamp(0, _LogoGeometry.samplePoints);
  }
}

class _LaserTrackPainter extends CustomPainter with _LogoGeometry {
  final double strokeProgress;

  _LaserTrackPainter({required this.strokeProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final arcLens = buildArcLengths(size);
    final totalLen = arcLens[_LogoGeometry.samplePoints];
    final targetLen = strokeProgress * totalLen;
    final endIdx = getArcIndex(arcLens, targetLen);

    if (endIdx <= 1) return;

    final laserPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final int startTailIdx = max(1, endIdx - 25);
    for (int i = startTailIdx; i <= endIdx; i++) {
      final t = i / _LogoGeometry.samplePoints;
      final factor = (i - startTailIdx) / (endIdx - startTailIdx);

      laserPaint.strokeWidth = 1.0 + (factor * 2.8);
      laserPaint.color = Color.lerp(
        const Color(0xFFCC3300).withValues(alpha: 0.0),
        const Color(0xFFFF9E88),
        factor,
      )!;

      final p0 = getPathPoint((i - 1) / _LogoGeometry.samplePoints, size);
      final p1 = getPathPoint(t, size);
      canvas.drawLine(p0, p1, laserPaint);
    }

    final tipPt = getPathPoint(endIdx / _LogoGeometry.samplePoints, size);

    canvas.drawCircle(
      tipPt,
      20,
      Paint()
        ..shader = ui.Gradient.radial(tipPt, 20, [
          const Color(0xFFFF9E88).withValues(alpha: 0.55),
          Colors.transparent,
        ]),
    );

    canvas.drawCircle(
      tipPt,
      7,
      Paint()
        ..shader = ui.Gradient.radial(
          tipPt,
          7,
          [
            Colors.white,
            const Color(0xFFCC3300).withValues(alpha: 0.8),
            Colors.transparent,
          ],
          const [0.0, 0.4, 1.0],
        ),
    );

    canvas.drawCircle(tipPt, 1.8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_LaserTrackPainter old) =>
      strokeProgress != old.strokeProgress;
}

class _GradientTranslateTransform extends GradientTransform {
  final double progress;
  const _GradientTranslateTransform(this.progress);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * -progress,
      bounds.height * progress,
      0,
    );
  }
}

class _SmoothCubicEase extends Curve {
  const _SmoothCubicEase();
  @override
  double transformInternal(double t) {
    if (t < 0.5) return 4 * t * t * t;
    return 1 - pow(-2 * t + 2, 3) / 2;
  }
}
