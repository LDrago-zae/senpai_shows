import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart';
import 'package:senpai_shows/screens/senpai_home.dart';
import 'package:senpai_shows/screens/senpai_signup.dart';
import '../components/slide_animation.dart';
// Hypothetical home screen

class SenpaiLogin extends StatefulWidget {
  const SenpaiLogin({super.key});

  @override
  State<SenpaiLogin> createState() => _SenpaiLoginScreenState();
}

class _SenpaiLoginScreenState extends State<SenpaiLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isMALLoading = false;

  final SenpaiAuth _auth = SenpaiAuth();
  bool _isLoading = false;
  bool _isGoogleLoading = false; // Separate loading state for Google Sign-In

  Future<void> _performLogin() async {
    setState(() => _isLoading = true);
    final userCredential = await _auth.signInWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (userCredential != null && userCredential.user != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Login successful!"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF4ECDC4),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pushReplacement(
          context,
          SlideAnimation(
            page: const SenpaiHome(),
            direction: AxisDirection.right,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login failed. Please check your credentials."),
          ),
        );
      }
    }
  }

  Future<void> _performAniListSignIn() async {
    setState(() => _isMALLoading = true);
    final success = await _auth.loginWithAniList();
    setState(() => _isMALLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("MyAnimeList login successful!"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: const Color(0xFF4ECDC4),
          duration: const Duration(seconds: 1),
        ),
      );
      Navigator.pushReplacement(
        context,
        SlideAnimation(
          page: const SenpaiHome(),
          direction: AxisDirection.right,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("MyAnimeList login failed or was cancelled"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _performGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    final userCredential = await _auth.signInWithGoogle();
    setState(() => _isGoogleLoading = false);

    if (userCredential != null && userCredential.user != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome, ${userCredential.user!.displayName}!"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF4ECDC4),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pushReplacement(
          context,
          SlideAnimation(
            page: const SenpaiHome(),
            direction: AxisDirection.right,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Google Sign-In cancelled by user."),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: CosmicGlassmorphicContainer(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Welcome back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Login to your account',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email or username',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF4ECDC4),
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (){_isLoading ? null : _performLogin;
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                  ),
                                  TextSpan(
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              SlideAnimation(
                                                page: const SenpaiSignup(),
                                                direction: AxisDirection.left,
                                              ),
                                            );
                                          },
                                    text: "Signup here",
                                    style: const TextStyle(
                                      color: Color(0xFF4ECDC4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Colors.white54,
                                    thickness: 0.5,
                                    endIndent: 8,
                                  ),
                                ),
                                Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.white54,
                                    thickness: 0.5,
                                    indent: 8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            _isMALLoading
                                                ? null
                                                : _performAniListSignIn,
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child:
                                              _isMALLoading
                                                  ? const CircularProgressIndicator(
                                                    color: Color(0xFF4ECDC4),
                                                    strokeWidth: 4,
                                                  )
                                                  : Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Image.asset(
                                                        'assets/icons/anilist.png',
                                                        fit: BoxFit.fill,
                                                        // color: Colors.white
                                                        //     .withValues(
                                                        //       alpha: 0.8,
                                                        //     ),
                                                      ),
                                                      // child: SvgPicture.asset(
                                                      //   'assets/icons/myanimelist1.svg',
                                                      //   colorFilter: const ColorFilter.mode(
                                                      //     Colors.white,
                                                      //     BlendMode.srcIn,
                                                      //   ),
                                                      // ),
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'AniList',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            _isGoogleLoading
                                                ? null
                                                : _performGoogleSignIn,
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child:
                                              _isGoogleLoading
                                                  ? const CircularProgressIndicator(
                                                    color: Color(0xFF4ECDC4),
                                                    strokeWidth: 4,
                                                  )
                                                  : Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/google.svg',
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Google',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
