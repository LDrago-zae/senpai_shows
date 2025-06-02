import 'package:firebase_auth/firebase_auth.dart';

class SenpaiAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Example: Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Example: Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email already in use, weak password)
      print('Failed to sign up: ${e.message}');
      return null;
    }
  }

  // Example: Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user not found, wrong password)
      print('Failed to sign in: ${e.message}');
      return null;
    }
  }

  // Example: Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}