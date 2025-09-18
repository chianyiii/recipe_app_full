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
    print("Starting register for $username...");
    final existing = await _db.getUserByUsername(username);
    if (existing != null) {
      print("Username already exists.");
      return false;
    }

    final hash = hashPassword(password);
    final user = User(username: username, passwordHash: hash);
    await _db.createUser(user);
    print("User $username created.");
    return true;
  }

  Future<bool> login(String username, String password) async {
    print("Attempting login for $username...");
    final user = await _db.getUserByUsername(username);
    if (user == null) {
      print("User not found.");
      return false;
    }
    final valid = user.passwordHash == hashPassword(password);
    print(valid ? "Login success." : "Invalid password.");
    return valid;
  }
}
