import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithGoogle() async {
    // Configure Google Sign In
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain auth details from request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with credential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Save user info to Firestore
    await _firestore.collection('Users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': userCredential.user!.email,
      'name': userCredential.user!.displayName,
      'profileImage': userCredential.user!.photoURL,
    }, SetOptions(merge: true));

    return userCredential;
  }

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
