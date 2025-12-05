// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class Authentication {
//   static Future<User?> signInWithGoogle({required BuildContext context}) async {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? user;
//
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//
//     try{
//       final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
//
//
//       if (googleSignInAccount != null) {
//         final GoogleSignInAuthentication googleSignInAuthentication =
//         await googleSignInAccount.authentication;
//
//         final AuthCredential credential = GoogleAuthProvider.credential(
//           accessToken: googleSignInAuthentication.accessToken,
//           idToken: googleSignInAuthentication.idToken,
//         );
//
//         try {
//           print("e");
//           final UserCredential userCredential =
//           await auth.signInWithCredential(credential);
//
//           user = userCredential.user;
//         } on FirebaseAuthException catch (e) {
//           if (e.code == 'account-exists-with-different-credential') {
//             print(e);
//             // handle the error here
//           }
//           else if (e.code == 'invalid-credential') {
//             print(e);
//             // handle the error here
//           }
//         } catch (e) {
//           print(e);
//           // handle the error here
//         }
//       }
//
//     }catch(e){
//       print(e);
//     }
//
//     return user;
//   }
//
//   static Future<void> signOut({required BuildContext context}) async {
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//
//     try {
//       if (!kIsWeb) {
//         await googleSignIn.signOut();
//       }
//       await FirebaseAuth.instance.signOut();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error signing out. Try again.'))
//         // Authentication.customSnackBar(
//         //   content: 'Error signing out. Try again.',
//         // ),
//       );
//     }
//   }
// }