import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Signup
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return user.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Error: ${e.code}");
      print("Firebase Message: ${e.message}");
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Login
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return user.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Error: ${e.code}");
      print("Firebase Message: ${e.message}");
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}