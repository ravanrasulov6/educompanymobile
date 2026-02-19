import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Authentication status
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Manages authentication state and user role
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _user?.role == UserRole.guest;
  UserRole get currentRole => _user?.role ?? UserRole.guest;

  /// Login with email and password (mock)
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Find matching demo user
      final matchedUser = UserModel.demoUsers.where(
        (u) => u.email == email.trim().toLowerCase(),
      );

      if (matchedUser.isNotEmpty && password == 'password123') {
        _user = matchedUser.first;
        _status = AuthStatus.authenticated;
      } else {
        _error = 'Invalid email or password';
        _status = AuthStatus.error;
      }
    } catch (e) {
      _error = 'An error occurred: $e';
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Sign up (mock)
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      _user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = 'Sign up failed: $e';
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Continue as guest with limited access
  void continueAsGuest() {
    _user = UserModel(
      id: 'guest',
      name: 'Guest User',
      email: '',
      role: UserRole.guest,
      createdAt: DateTime.now(),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
