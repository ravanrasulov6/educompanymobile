import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Authentication status
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Manages authentication state and user role
class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _user?.role == UserRole.guest;
  UserRole get currentRole => _user?.role ?? UserRole.guest;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _fetchUserProfile(session.user.id, session.user.email);
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String userId, String? email) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      _user = UserModel.fromJson({
        ...data,
        'email': email,
      });
      _status = AuthStatus.authenticated;
    } catch (e) {
      debugPrint('Profile fetch error: $e');
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Login with Supabase
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      // Profile will be loaded via auth listener
    } on AuthException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
    } catch (e) {
      _error = 'Giriş uğursuz oldu: $e';
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Sign up with Supabase
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': name,
          'role': role.name,
        },
      );
      // Profile will be created by database trigger and loaded via auth listener
    } on AuthException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
    } catch (e) {
      _error = 'Qeydiyyat uğursuz oldu: $e';
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Continue as guest
  void continueAsGuest() {
    _user = UserModel(
      id: 'guest',
      name: 'Qonaq İstifadəçi',
      email: '',
      role: UserRole.guest,
      createdAt: DateTime.now(),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
