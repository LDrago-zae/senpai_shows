import 'dart:ui';
import 'package:flutter/material.dart';

// Light Black Glassmorphic Container
class LightBlackGlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blurStrength;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const LightBlackGlassmorphicContainer({
    super.key,
    required this.child,
    this.blurStrength = 6.0,
    this.borderRadius = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurStrength,
                  sigmaY: blurStrength,
                ),
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: .15),
                        Colors.black.withValues(alpha: .25),
                      ],
                    ),
                    border: borderRadius > 0
                        ? Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.0,
                    )
                        : null,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Blue Gradient Glassmorphic Container
// class BlueGradientGlassmorphicContainer extends StatelessWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const BlueGradientGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF1E3A8A).withOpacity(0.7), // Dark Blue
//               Color(0xFF3B82F6).withOpacity(0.5), // Lighter Blue
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(
//                   sigmaX: blurStrength,
//                   sigmaY: blurStrength,
//                 ),
//                 child: Container(
//                   padding: padding,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.white.withOpacity(0.1),
//                         Colors.black.withOpacity(0.3),
//                       ],
//                     ),
//                     border: borderRadius > 0
//                         ? Border.all(
//                       color: Color(0xFF60A5FA).withOpacity(0.3),
//                       width: 1.0,
//                     )
//                         : null,
//                     borderRadius: BorderRadius.circular(borderRadius),
//                   ),
//                   child: child,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Purple Gradient Glassmorphic Container
// class PurpleGradientGlassmorphicContainer extends StatelessWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const PurpleGradientGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF067C72).withOpacity(0.9), // Dark Purple
//               Color(0xFF7C3AED).withOpacity(0.8), // Lighter Purple
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(
//                   sigmaX: blurStrength,
//                   sigmaY: blurStrength,
//                 ),
//                 child: Container(
//                   padding: padding,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.white.withOpacity(0.1),
//                         Colors.black.withOpacity(0.3),
//                       ],
//                     ),
//                     border: borderRadius > 0
//                         ? Border.all(
//                       color: Color(0xFFA78BFA).withOpacity(0.3),
//                       width: 1.0,
//                     )
//                         : null,
//                     borderRadius: BorderRadius.circular(borderRadius),
//                   ),
//                   child: child,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Neon Cyberpunk Gradient Container
// class NeonCyberpunkGlassmorphicContainer extends StatelessWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const NeonCyberpunkGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF701A75).withOpacity(0.7), // Dark Fuchsia
//               Color(0xFF06B6D4).withOpacity(0.5), // Cyan
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(
//                   sigmaX: blurStrength,
//                   sigmaY: blurStrength,
//                 ),
//                 child: Container(
//                   padding: padding,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.white.withOpacity(0.15),
//                         Colors.black.withOpacity(0.25),
//                       ],
//                     ),
//                     border: borderRadius > 0
//                         ? Border.all(
//                       color: Color(0xFFEC4899).withOpacity(0.3),
//                       width: 1.0,
//                     )
//                         : null,
//                     borderRadius: BorderRadius.circular(borderRadius),
//                   ),
//                   child: child,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Emerald Twilight Gradient Container
// class EmeraldTwilightGlassmorphicContainer extends StatelessWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const EmeraldTwilightGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0F766E).withOpacity(0.7), // Dark Teal
//               Color(0xFF065F46).withOpacity(0.5), // Deep Green
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(
//                   sigmaX: blurStrength,
//                   sigmaY: blurStrength,
//                 ),
//                 child: Container(
//                   padding: padding,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.white.withOpacity(0.15),
//                         Colors.black.withOpacity(0.25),
//                       ],
//                     ),
//                     border: borderRadius > 0
//                         ? Border.all(
//                       color: Color(0xFF34D399).withOpacity(0.3),
//                       width: 1.0,
//                     )
//                         : null,
//                     borderRadius: BorderRadius.circular(borderRadius),
//                   ),
//                   child: child,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Amethyst Glow Gradient Container
// class AmethystGlowGlassmorphicContainer extends StatelessWidget {
//   final Widget child;
//   final double blurStrength;
//   final double borderRadius;
//   final EdgeInsetsGeometry? padding;
//
//   const AmethystGlowGlassmorphicContainer({
//     super.key,
//     required this.child,
//     this.blurStrength = 6.0,
//     this.borderRadius = 16.0,
//     this.padding,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF5B21B6).withOpacity(0.7), // Deep Violet
//               Color(0xFFD946EF).withOpacity(0.5), // Magenta
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//         Positioned.fill(
//         child: BackdropFilter(
//         filter: ImageFilter.blur(
//           sigmaX: blurStrength,
//           sigmaY: blurStrength,
//         ),
//         child: Container(
//           padding: padding,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors ocorreu: Colors((
//             Colors.white.withOpacity(0.15),
//             Colors.black.withOpacity(0.25),
//             ],
//           ),
//           border: borderRadius > 0
//               ? Border.all(
//             color: Color(0xFF8A55F7).withOpacity(0.3),
//             width: 1.0,
//           )
//               : null,
//           borderRadius: BorderRadius.circular(borderRadius),
//         ),
//         child: child,
//       ),
//     ),
//     ),
//     ],
//     ),
//     ),
//     );
//   }
// }