import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart'; // Import SenpaiAuth
import 'senpai_login.dart'; // Make sure to import your login screen
// Import a screen to navigate to after successful signup, e.g., a home screen
// import 'senpai_home.dart'; // Example: replace with your actual home screen

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

  final SenpaiAuth _auth = SenpaiAuth(); // Create an instance of SenpaiAuth
  bool _isLoading = false; // To show a loading indicator

  Future<void> _performSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      // Show error if passwords don't match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
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
      // Signup successful, navigate to home or login screen
      // For example, navigate to login screen:
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SenpaiLogin()), // Or your home screen
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful! Please login.")),
        );
      }
    } else {
      // Signup failed, error is printed in SenpaiAuth class
      // You can show a generic error message here
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
          child: GlassmorphicContainer(
            child: Column(
              children: [
                // Back button
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
                // Centered content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
            
                            // Title text
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
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
            
                            // Name field
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Full name',
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
                                  Icons.person_outline,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
            
                            // Email field
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email address',
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
            
                            // Confirm Password field
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
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
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
            
                            // Terms checkbox
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
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
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
            
                            // Signup button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading || !_agreeToTerms
                                    ? null
                                    : _performSignUp, // Call _performSignUp
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
            
                            // Login link
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SenpaiLogin(),
                                          ),
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
            
                            const SizedBox(height: 30),
            
                            // Social login buttons
                            Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: Row(
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