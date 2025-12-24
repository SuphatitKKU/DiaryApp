import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated Aurora background with floating blobs
class AuroraBackground extends StatefulWidget {
  final Widget child;
  final bool showBlobs;
  final bool animate;

  const AuroraBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
    this.animate = true,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFAFA), Color(0xFFFDF4FF), Color(0xFFFFF0F5)],
        ),
      ),
      child: Stack(
        children: [
          // Aurora gradient overlay
          Positioned.fill(
            child: CustomPaint(painter: _AuroraGradientPainter()),
          ),
          // Floating blobs
          if (widget.showBlobs) ...[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Top left blob - Fuchsia
                    Positioned(
                      top: -100 + (_controller.value * 30),
                      left: -100 + (_controller.value * 20),
                      child: _AuroraBlob(
                        size: 300,
                        color: AppTheme.auroraFuchsia.withValues(alpha: 0.15),
                        blur: 80,
                      ),
                    ),
                    // Bottom right blob - Blue
                    Positioned(
                      bottom: -150 + (_controller.value * 40),
                      right: -100 - (_controller.value * 30),
                      child: _AuroraBlob(
                        size: 350,
                        color: AppTheme.auroraBlue.withValues(alpha: 0.12),
                        blur: 100,
                      ),
                    ),
                    // Center blob - Pink
                    Positioned(
                      top:
                          MediaQuery.of(context).size.height * 0.3 +
                          (math.sin(_controller.value * math.pi) * 20),
                      right: 50 + (_controller.value * 25),
                      child: _AuroraBlob(
                        size: 200,
                        color: AppTheme.auroraPink.withValues(alpha: 0.2),
                        blur: 70,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          // Child content
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

/// Custom painter for subtle aurora gradient overlay
class _AuroraGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top left purple glow
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.9, -0.8),
        radius: 1.0,
        colors: [
          const Color(0xFFAF25F4).withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    // Right side blue glow
    final paint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.9, 0.3),
        radius: 1.0,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);

    // Bottom pink glow
    final paint3 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.8),
        radius: 1.2,
        colors: [
          const Color(0xFFEC4899).withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Individual floating blob widget
class _AuroraBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _AuroraBlob({
    required this.size,
    required this.color,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: blur, spreadRadius: blur * 0.5),
        ],
      ),
    );
  }
}
