import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _error = null;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUpWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
