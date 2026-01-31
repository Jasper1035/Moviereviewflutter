import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

class AuthenticationFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //sign up function/method
  Future<User?> signUp(String fullName, String email, String password) async {
    try {
      //create user in firebase auth.
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
        });
        return user;
      }
    } catch (e) {
      print('Sign Up error $e');
      return null;
    }
    return null;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign in error $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
