import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'app_database.dart';

class AuthService {
  final AppDatabase _db = AppDatabase.instance;
  static const String _salt = "SOME_STATIC_SALT_FOR_DEMO"; // demo only

  String hashPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register(String username, String password) async {
    final existing = await _db.getUserByUsername(username);
    if (existing != null) return false;
    final hash = hashPassword(password);
    final user = User(username: username, passwordHash: hash);
    await _db.createUser(user);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final user = await _db.getUserByUsername(username);
    if (user == null) return false;
    return user.passwordHash == hashPassword(password);
  }
}
