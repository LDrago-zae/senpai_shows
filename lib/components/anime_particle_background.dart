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
    this.blurStrength = 4.0,
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
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _borderAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
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
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1326).withOpacity(1.0 - _gradientAnimation.value * 0.15),
                  Color(0xFF2C1A4D).withOpacity(1.0 - _gradientAnimation.value * 0.15),
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
                      willChange: true,
                      child: Container(),
                    );
                  },
                ),
                // Hexagonal pattern
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.08,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF34D399).withOpacity(0.1),
                              Color(0xFFA78BFA).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: CustomPaint(
                          painter: HexagonGridPainter(),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Glassmorphic overlay
                Positioned.fill(
                  child: BackdropFilter(
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
                            Colors.white.withOpacity(0.1),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                        border: widget.borderRadius > 0
                            ? Border.all(
                          color: Color(0xFF6B7280).withOpacity(_borderAnimation.value),
                          width: 1.0,
                        )
                            : null,
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final double animationValue;

  StarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < 75; i++) {
      final isPink = random.nextDouble() < 0.1; // 10% chance for pink stars
      final paint = Paint()
        ..color = isPink
            ? Color(0xFFFFD1DC).withOpacity(0.4 + animationValue * 0.3)
            : Colors.white.withOpacity(0.4 + animationValue * 0.3);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + random.nextDouble() * 0.7;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HexagonGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double radius = 30.0;
    final double apothem = radius * cos(pi / 6);
    final double side = radius * sin(pi / 6) * 2;

    for (double y = -radius; y < size.height + radius; y += apothem * 2) {
      for (double x = -radius; x < size.width + radius; x += side * 1.5) {
        final offsetX = (y / (apothem * 2)).floor() % 2 == 0 ? x : x + side * 0.75;
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (pi / 3) * i + (pi / 6);
          final px = offsetX + radius * cos(angle);
          final py = y + radius * sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class CosmicGlassmorphicContainer extends StatefulWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const CosmicGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   State<CosmicGlassmorphicContainer> createState() => _CosmicGlassmorphicContainerState();
// }
//
// class _CosmicGlassmorphicContainerState extends State<CosmicGlassmorphicContainer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _gradientAnimation;
//   late Animation<double> _starAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _gradientAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//
//     _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   const Color(0xFF0A001A).withOpacity(1.0 - _gradientAnimation.value * 0.2),
//                   const Color(0xFF2A004D).withOpacity(1.0 - _gradientAnimation.value * 0.2),
//                 ],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Twinkling stars
//                 AnimatedBuilder(
//                   animation: _starAnimation,
//                   builder: (context, child) {
//                     return CustomPaint(
//                       painter: StarPainter(_starAnimation.value),
//                       willChange: true,
//                       child: Container(),
//                     );
//                   },
//                 ),
//                 // Neon hexagonal pattern
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: Opacity(
//                       opacity: 0.15,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               const Color(0xFF00C4CC).withOpacity(0.1),
//                               const Color(0xFF4A007A).withOpacity(0.1),
//                             ],
//                             stops: const [0.4, 0.6],
//                           ),
//                         ),
//                         child: ClipPath(
//                           clipper: HexagonClipper(),
//                           child: Container(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Glassmorphic overlay for content
//                 Positioned.fill(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(
//                       sigmaX: widget.blurStrength,
//                       sigmaY: widget.blurStrength,
//                     ),
//                     child: Container(
//                       padding: widget.padding,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Colors.black.withOpacity(0.3),
//                             Colors.black.withOpacity(0.1),
//                           ],
//                         ),
//                         // border: widget.borderRadius > 0
//                         //     ? Border.all(
//                         //   color: const Color(0xFF00C4CC).withOpacity(0.5),
//                         //   width: 1.0,
//                         // )
//                         //     : null,
//                         borderRadius: BorderRadius.circular(widget.borderRadius),
//                       ),
//                       child: widget.child,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // Custom painter for twinkling stars
// class StarPainter extends CustomPainter {
//   final double animationValue;
//
//   StarPainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.white.withOpacity(0.3 + animationValue * 0.2);
//     final random = Random();
//
//     for (int i = 0; i < 50; i++) {
//       final x = random.nextDouble() * size.width;
//       final y = random.nextDouble() * size.height;
//       final radius = random.nextDouble() * 1.5;
//       canvas.drawCircle(Offset(x, y), radius, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

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

//import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class CosmicGlassmorphicContainer extends StatefulWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const CosmicGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   State<CosmicGlassmorphicContainer> createState() => _CosmicGlassmorphicContainerState();
// }
//
// class _CosmicGlassmorphicContainerState extends State<CosmicGlassmorphicContainer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _gradientAnimation;
//   late Animation<double> _starAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _gradientAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//
//     _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   const Color(0xFF0A001A).withOpacity(1.0 - _gradientAnimation.value * 0.2),
//                   const Color(0xFF2A004D).withOpacity(1.0 - _gradientAnimation.value * 0.2),
//                 ],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Twinkling stars
//                 AnimatedBuilder(
//                   animation: _starAnimation,
//                   builder: (context, child) {
//                     return CustomPaint(
//                       painter: StarPainter(_starAnimation.value),
//                       willChange: true,
//                       child: Container(),
//                     );
//                   },
//                 ),
//                 // Neon hexagonal pattern
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: Opacity(
//                       opacity: 0.15,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               const Color(0xFF00C4CC).withOpacity(0.1),
//                               const Color(0xFF4A007A).withOpacity(0.1),
//                             ],
//                             stops: const [0.4, 0.6],
//                           ),
//                         ),
//                         child: ClipPath(
//                           clipper: HexagonClipper(),
//                           child: Container(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Glassmorphic overlay for content
//                 Positioned.fill(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(
//                       sigmaX: widget.blurStrength,
//                       sigmaY: widget.blurStrength,
//                     ),
//                     child: Container(
//                       padding: widget.padding,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Colors.black.withOpacity(0.3),
//                             Colors.black.withOpacity(0.1),
//                           ],
//                         ),
//                         // border: widget.borderRadius > 0
//                         //     ? Border.all(
//                         //   color: const Color(0xFF00C4CC).withOpacity(0.5),
//                         //   width: 1.0,
//                         // )
//                         //     : null,
//                         borderRadius: BorderRadius.circular(widget.borderRadius),
//                       ),
//                       child: widget.child,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // Custom painter for twinkling stars
// class StarPainter extends CustomPainter {
//   final double animationValue;
//
//   StarPainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.white.withOpacity(0.3 + animationValue * 0.2);
//     final random = Random();
//
//     for (int i = 0; i < 50; i++) {
//       final x = random.nextDouble() * size.width;
//       final y = random.nextDouble() * size.height;
//       final radius = random.nextDouble() * 1.5;
//       canvas.drawCircle(Offset(x, y), radius, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// // Custom clipper for hexagonal pattern
// class HexagonClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     double width = size.width;
//     double height = size.height;
//     double radius = 50.0;
//
//     path.moveTo(width / 2, 0); // Top center
//     path.lineTo(width - radius, height * 0.25); // Top right
//     path.lineTo(width - radius, height * 0.75); // Bottom right
//     path.lineTo(width / 2, height); // Bottom center
//     path.lineTo(radius, height * 0.75); // Bottom left
//     path.lineTo(radius, height * 0.25); // Top left
//     path.close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }


//import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class CosmicGlassmorphicContainer extends StatefulWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const CosmicGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 4.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   State<CosmicGlassmorphicContainer> createState() => _CosmicGlassmorphicContainerState();
// }
//
// class _CosmicGlassmorphicContainerState extends State<CosmicGlassmorphicContainer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _gradientAnimation;
//   late Animation<double> _starAnimation;
//   late Animation<double> _borderAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 15),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _gradientAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOutSine,
//     );
//
//     _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//
//     _borderAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF0D1326).withOpacity(1.0 - _gradientAnimation.value * 0.15),
//                   Color(0xFF2C1A4D).withOpacity(1.0 - _gradientAnimation.value * 0.15),
//                 ],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Twinkling stars
//                 AnimatedBuilder(
//                   animation: _starAnimation,
//                   builder: (context, child) {
//                     return CustomPaint(
//                       painter: StarPainter(_starAnimation.value),
//                       willChange: true,
//                       child: Container(),
//                     );
//                   },
//                 ),
//                 // Hexagonal pattern
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: Opacity(
//                       opacity: 0.08,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               Color(0xFF34D399).withOpacity(0.1),
//                               Color(0xFFA78BFA).withOpacity(0.1),
//                             ],
//                           ),
//                         ),
//                         child: CustomPaint(
//                           painter: HexagonGridPainter(),
//                           child: Container(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Glassmorphic overlay
//                 Positioned.fill(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(
//                       sigmaX: widget.blurStrength,
//                       sigmaY: widget.blurStrength,
//                     ),
//                     child: Container(
//                       padding: widget.padding,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.black.withOpacity(0.2),
//                           ],
//                         ),
//                         border: widget.borderRadius > 0
//                             ? Border.all(
//                                 color: Color(0xFF6B7280).withOpacity(_borderAnimation.value),
//                                 width: 1.0,
//                               )
//                             : null,
//                         borderRadius: BorderRadius.circular(widget.borderRadius),
//                       ),
//                       child: widget.child,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class StarPainter extends CustomPainter {
//   final double animationValue;
//
//   StarPainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final random = Random();
//     for (int i = 0; i < 75; i++) {
//       final isPink = random.nextDouble() < 0.1; // 10% chance for pink stars
//       final paint = Paint()
//         ..color = isPink
//             ? Color(0xFFFFD1DC).withOpacity(0.4 + animationValue * 0.3)
//             : Colors.white.withOpacity(0.4 + animationValue * 0.3);
//       final x = random.nextDouble() * size.width;
//       final y = random.nextDouble() * size.height;
//       final radius = 0.5 + random.nextDouble() * 0.7;
//       canvas.drawCircle(Offset(x, y), radius, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// class HexagonGridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.5;
//
//     final double radius = 30.0;
//     final double apothem = radius * cos(pi / 6);
//     final double side = radius * sin(pi / 6) * 2;
//
//     for (double y = -radius; y < size.height + radius; y += apothem * 2) {
//       for (double x = -radius; x < size.width + radius; x += side * 1.5) {
//         final offsetX = (y / (apothem * 2)).floor() % 2 == 0 ? x : x + side * 0.75;
//         final path = Path();
//         for (int i = 0; i < 6; i++) {
//           final angle = (pi / 3) * i + (pi / 6);
//           final px = offsetX + radius * cos(angle);
//           final py = y + radius * sin(angle);
//           if (i == 0) {
//             path.moveTo(px, py);
//           } else {
//             path.lineTo(px, py);
//           }
//         }
//         path.close();
//         canvas.drawPath(path, paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }