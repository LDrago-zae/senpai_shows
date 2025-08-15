import 'package:flutter/material.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart';
import 'package:senpai_shows/layout/main_navigation.dart';
import 'package:senpai_shows/screens/senpai_login.dart';

class AuthWrapper extends StatelessWidget {
  final SenpaiAuth _auth = SenpaiAuth();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4))),
          );
        }
        if (snapshot.hasData && snapshot.data != null && _auth.isGoogleSignIn()) {
          return const MainNavigation();
        }
        return const SenpaiLogin();
      },
    );
  }
}