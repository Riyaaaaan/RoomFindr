import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      // Convert email to lowercase
      String lowercaseEmail = email.toLowerCase();

      // Sign in user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: lowercaseEmail, password: password);

      // Save user info if it doesn't exist
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': lowercaseEmail,
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Convert email to lowercase
      String lowercaseEmail = email.toLowerCase();

      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: lowercaseEmail,
        password: password,
      );

      // Save user info in Firestore
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': lowercaseEmail,
        'name': name,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
