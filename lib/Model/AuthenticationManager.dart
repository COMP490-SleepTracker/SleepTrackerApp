import 'package:flutter/material.dart';

abstract class AuthenticationManager extends ChangeNotifier {
  bool get isAuthenticated;
  Future<void> authenticate(String username, String password);
  Future<void> signOut();
}

class TestAuthenticationManagerImpl extends AuthenticationManager {
  @override
  bool get isAuthenticated => _isAuthenticated;
  bool _isAuthenticated = false;

  @override
  Future<void> authenticate(String username, String password) async {
    if(username == "admin" && password == "password") {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}