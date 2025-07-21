import 'dart:ui';
import 'package:flutter/material.dart';

class LightBlackGlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final double blurStrength;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const LightBlackGlassmorphicContainer({
    super.key,
    required this.child,
    this.imagePath = 'assets/senpaiAssets/solo.jpg',
    this.blurStrength = 9.0,
    this.borderRadius = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background Asset Image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.error, color: Colors.redAccent, size: 48),
                ),
              ),
            ),
          ),
          // Glassmorphic Overlay with BackdropFilter
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
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                  border: borderRadius > 0
                      ? Border.all(
                    color: Colors.tealAccent.withOpacity(0.3),
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
    );
  }
}