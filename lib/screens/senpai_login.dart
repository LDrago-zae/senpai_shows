import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart';
import 'package:senpai_shows/screens/senpai_signup.dart';

import '../components/slide_animation.dart';

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

  final SenpaiAuth _auth = SenpaiAuth(); // Create an instance of SenpaiAuth
  bool _isLoading = false; // To show a loading indicator

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
    });

    final userCredential = await _auth.signInWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (userCredential != null && userCredential.user != null) {
      // Login successful, navigate to home screen
      if (mounted) {
        // Replace with your actual home screen navigation
        // For example, if you have a SenpaiHome screen:
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SenpaiHome()),
        // );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!"),
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF4ECDC4),
            duration: const Duration(seconds: 1),
          ),
        );
        // For now, let's just pop if no home screen is defined
        // Navigator.pop(context); // Or navigate to your main app screen
      }
    } else {
      // Login failed, error is printed in SenpaiAuth class
      // You can show a generic error message here
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Please check your credentials.")),
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
          child: GlassmorphicContainer(
            child: Column(
              children: [
                // Back button moved to the top
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context), // Pop the current screen
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Centered content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16), // Space after back button
            
                            // Welcome text
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
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
            
                            // Email field
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email or username',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
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
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
            
                            // Password field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
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
                                  color: Colors.white.withOpacity(0.5),
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
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
            
                            // Remember me and forgot password
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
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                // TextButton(
                                //   onPressed: () {
                                //     // Forgot password logic
                                //     // You might want to implement a password reset feature here
                                //     // using _auth.sendPasswordResetEmail(email)
                                //     if (_emailController.text.trim().isNotEmpty) {
                                //       _auth.sendPasswordResetEmail(_emailController.text.trim()).then((_) {
                                //         ScaffoldMessenger.of(context).showSnackBar(
                                //           SnackBar(content: Text("Password reset email sent to ${_emailController.text.trim()}")),
                                //         );
                                //       }).catchError((e) {
                                //         ScaffoldMessenger.of(context).showSnackBar(
                                //           SnackBar(content: Text("Failed to send reset email: ${e.message}")),
                                //         );
                                //       });
                                //     } else {
                                //       ScaffoldMessenger.of(context).showSnackBar(
                                //         const SnackBar(content: Text("Please enter your email address to reset password.")),
                                //       );
                                //     }
                                //   },
                                //   child: Text(
                                //     'Forgot password?',
                                //     style: TextStyle(
                                //       color: Colors.white.withOpacity(0.9),
                                //       fontSize: 12,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 24),
            
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (){_isLoading ? null : _performLogin;
                                  }, // Call _performLogin
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
            
                            // Sign up text
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          SlideAnimation(page: const SenpaiSignup(), direction: AxisDirection.left),
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
            
                            // Or continue with divider
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
                                    color: Colors.white.withOpacity(0.7),
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
            
                            const SizedBox(height: 20),
            
                            // Social login buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Facebook login logic
                                  },
                                  icon: const Icon(
                                    Icons.facebook,
                                    color: Color(0xFF1877F2),
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    // Google login logic
                                  },
                                  icon: const Icon(
                                    Icons.g_mobiledata, // Consider using a proper Google icon
                                    color: Color(0xFFDB4437),
                                    size: 40,
                                  ),
                                ),
                              ],
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