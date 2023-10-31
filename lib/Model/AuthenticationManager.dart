import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthenticationManager extends ChangeNotifier {
 bool get isAuthenticated;
 Future<void> authenticate(String username, String password);
  
 Future<void> loginWithEmailAndPassword({required String email,required String password, });
 Future<void> signInWithEmailAndPassword({required String email,required String password, });
 Future<void> googleLogin();

  // Future<void> authenticateWithGoogle();
  Future<void> signOut();
} 

class TestAuthenticationManagerImpl extends AuthenticationManager {
  @override
  bool get isAuthenticated => _isAuthenticated;
  bool _isAuthenticated = false;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  
  @override
  Future<void> loginWithEmailAndPassword({required String email,required String password, }) async {

    try
    {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password).then((value) => _isAuthenticated = !_isAuthenticated);
    }
    catch(e)
    {
      // there were issues with firebase authentication
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    notifyListeners();
  }

  @override
  Future<void> authenticate(String username, String password) async {
    if(username == "admin" && password == "password") {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }


  GoogleSignInAccount? user;
  GoogleSignInAccount get googleUser => user!;
  final googleSignIn = GoogleSignIn();


  @override
  Future<void> googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    user = googleUser;

    //Fetch the authentification
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);
    _isAuthenticated = true; 
    notifyListeners();
  }


  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    await firebaseAuth.signOut();
    notifyListeners();
  }
}