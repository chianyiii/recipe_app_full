import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _loggedIn = false;
  String? _username;

  bool get loggedIn => _loggedIn;
  String? get username => _username;

  Future<bool> login(String username, String password) async {
    final ok = await _auth.login(username, password);
    if (ok) {
      _loggedIn = true;
      _username = username;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> register(String username, String password) async {
    final ok = await _auth.register(username, password);
    if (ok) {
      _loggedIn = true;
      _username = username;
      notifyListeners();
    }
    return ok;
  }

  void logout() {
    _loggedIn = false;
    _username = null;
    notifyListeners();
  }
}
