import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class CosmicGlassmorphicContainer extends StatefulWidget {
  final Widget child;
  final double blurStrength;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CosmicGlassmorphicContainer({
    super.key,
    required this.child,
    this.blurStrength = 6.0,
    this.borderRadius = 16.0,
    this.padding,
  });

  @override
  State<CosmicGlassmorphicContainer> createState() => _CosmicGlassmorphicContainerState();
}

class _CosmicGlassmorphicContainerState extends State<CosmicGlassmorphicContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnimation;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A001A).withOpacity(1.0 - _gradientAnimation.value * 0.2), // Dark space
                const Color(0xFF2A004D).withOpacity(1.0 - _gradientAnimation.value * 0.2), // Dark nebula
              ],
            ),
          ),
          child: Stack(
            children: [
              // Twinkling stars
              AnimatedBuilder(
                animation: _starAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: StarPainter(_starAnimation.value),
                    child: Container(),
                  );
                },
              ),
              // Neon hexagonal pattern
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF00C4CC).withOpacity(0.1), // Dark neon teal
                      const Color(0xFF4A007A).withOpacity(0.1), // Dark neon purple
                    ],
                    stops: const [0.4, 0.6],
                  ),
                ),
                child: ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Glassmorphic overlay
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurStrength,
                  sigmaY: widget.blurStrength,
                ),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF00C4CC).withOpacity(0.5), // Neon cyan border
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for twinkling stars
class StarPainter extends CustomPainter {
  final double animationValue;

  StarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3 + animationValue * 0.2);
    final random = Random();

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom clipper for hexagonal pattern
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;
    double radius = 50.0;

    path.moveTo(width / 2, 0); // Top center
    path.lineTo(width - radius, height * 0.25); // Top right
    path.lineTo(width - radius, height * 0.75); // Bottom right
    path.lineTo(width / 2, height); // Bottom center
    path.lineTo(radius, height * 0.75); // Bottom left
    path.lineTo(radius, height * 0.25); // Top left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}