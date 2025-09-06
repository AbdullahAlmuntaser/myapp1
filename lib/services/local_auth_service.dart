import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database_helper.dart';
import '../user_model.dart';

class LocalAuthService with ChangeNotifier {
  User? _currentUser; // Holds the currently logged-in user
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Constructor - could try to load a persisted user session here if implemented
  LocalAuthService() {
    // In a real app, you might try to load a user session from SharedPreferences
    // or secure storage here to keep the user logged in across app restarts.
    // For now, we start with no user logged in.
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> signIn(String username, String password) async {
    final user = await _databaseHelper.getUserByUsername(username);
    if (user != null) {
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash == hashedPassword) {
        _currentUser = user;
        notifyListeners(); // Notify UI that user state has changed
        return true;
      }
    }
    return false; // Authentication failed
  }

  Future<bool> signUp(String username, String password, String role) async {
    // Check if user already exists
    final existingUser = await _databaseHelper.getUserByUsername(username);
    if (existingUser != null) {
      return false; // User with this username already exists
    }

    final hashedPassword = _hashPassword(password);
    final newUser = User(
      username: username,
      passwordHash: hashedPassword,
      role: role,
    );

    final id = await _databaseHelper.createUser(newUser);
    if (id > 0) {
      // Optionally, automatically log in the new user
      _currentUser = newUser.copyWith(id: id); // Assuming copyWith exists, or just create new user object with ID
      notifyListeners();
      return true;
    }
    return false;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners(); // Notify UI that user state has changed
  }
}

extension on User {
  // Helper to create a new User object with updated fields (e.g., after insertion gives an ID)
  User copyWith({int? id, String? username, String? passwordHash, String? role}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
    );
  }
}
