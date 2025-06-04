import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3. Create a new credential using the Google auth tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Example: Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  void signIn() async {
    final userCredential = await signInWithGoogle();
    if (userCredential != null) {
      // Successfully signed in
      print('User: ${userCredential.user?.displayName}');
    } else {
      // Sign in failed or was canceled
      print('Sign in failed');
    }
  }

}