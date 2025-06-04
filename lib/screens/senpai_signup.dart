import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart';
import 'senpai_login.dart';

class SenpaiSignup extends StatefulWidget {
  const SenpaiSignup({super.key});

  @override
  State<SenpaiSignup> createState() => _SenpaiSignupScreenState();
}

class _SenpaiSignupScreenState extends State<SenpaiSignup> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final SenpaiAuth _auth = SenpaiAuth();
  bool _isLoading = false;

  Future<void> _performSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the terms and conditions.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userCredential = await _auth.signUpWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (userCredential != null && userCredential.user != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SenpaiLogin()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful! Please login.")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed. Please try again.")),
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
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join us today',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Full name',
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
                                  Icons.person_outline,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email address',
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
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
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
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF4ECDC4),
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                      ),
                                      children: [
                                        const TextSpan(text: "I agree to the "),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: const TextStyle(
                                            color: Color(0xFF4ECDC4),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: " and "),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: const TextStyle(
                                            color: Color(0xFF4ECDC4),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading || !_agreeToTerms ? null : _performSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'Create Account',
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
                                  const TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const SenpaiLogin()),
                                        );
                                      },
                                    text: "Login here",
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
                                    thickness: .5,
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
                                    thickness: .5,
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
                                        onTap: () {},
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue.shade900,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              // MyAnimeList login logic
                                            },
                                            icon: SvgPicture.asset(
                                              'assets/icons/myanimelist1.svg',
                                              colorFilter: ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'MyAnimeList',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 30),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              // Google login logic
                                            },
                                            icon: SvgPicture.asset(
                                              'assets/icons/google.svg',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Google',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}