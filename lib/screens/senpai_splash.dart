import 'package:flutter/material.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart';
import 'package:senpai_shows/layout/main_navigation.dart';
import 'package:senpai_shows/screens/senpai_login.dart';
import '../components/slide_animation.dart';

class SenpaiSplash extends StatefulWidget {
  const SenpaiSplash({super.key});

  @override
  SenpaiSplashState createState() => SenpaiSplashState();
}

class SenpaiSplashState extends State<SenpaiSplash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  final SenpaiAuth _auth = SenpaiAuth();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward().then((_) => _navigateAfterAnimation());
  }

  Future<void> _navigateAfterAnimation() async {
    if (!mounted) return;

    try {
      // Check if user is signed in with Google
      if (_auth.currentUser != null && _auth.isGoogleSignIn()) {
        Navigator.pushReplacement(
          context,
          SlideAnimation(
            page: const MainNavigation(),
            direction: AxisDirection.right,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          SlideAnimation(
            page: const SenpaiLogin(),
            direction: AxisDirection.up,
          ),
        );
      }
    } catch (e) {
      print('Auth check error: $e');
      Navigator.pushReplacement(
        context,
        SlideAnimation(
          page: const SenpaiLogin(),
          direction: AxisDirection.up,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with dark overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/senpaiAssets/fr.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),

          // Animated logo
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/senpaiAssets/logo4.png",
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Get Started Button
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _opacityAnimation.value)),
                      child: child,
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    // Stop animation and navigate immediately
                    _controller.stop();
                    _navigateAfterAnimation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF44B7B8),
                        width: 1,
                      ),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF4ECDC4).withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}