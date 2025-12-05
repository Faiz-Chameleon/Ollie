import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';

signInWithGoogle() async {
  try {
    print("Starting Google sign-in process...");

    // Check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      print("Firebase not initialized!");
      return null;
    }

    // Initialize GoogleSignIn with proper configuration
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    print("Triggering Google sign-in...");
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    print("Google sign-in result: $googleUser");

    if (googleUser != null) {
      print("Google user selected: ${googleUser.email}");

      // Obtain the auth details from the request
      print("Getting authentication details...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print(
          "Access token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}");
      print("ID token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}");

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in with Firebase...");
      // Once signed in, return the UserCredential
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print("Firebase sign-in successful: ${userCredential.user?.email}");
      print("User UID: ${userCredential.user?.uid}");
      return userCredential;
    } else {
      print("Google sign-in cancelled by user");
      return null;
    }
  } catch (e) {
    print("Google sign-in error: $e");
    print("Error type: ${e.runtimeType}");

    // Check for specific error types
    if (e is FirebaseAuthException) {
      print("Firebase Auth Error Code: ${e.code}");
      print("Firebase Auth Error Message: ${e.message}");
    }

    return null;
  }
}

signOut() async {
  try {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleUser =
        await GoogleSignIn(scopes: <String>["email"]);

    await _firebaseAuth.signOut();
    await googleUser.signOut();
    print("Sign out successful");
  } catch (e) {
    print("Sign out error: $e");
  }
}
