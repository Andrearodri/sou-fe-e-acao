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

  /// Valida se o email eh valido
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida se a senha atende aos criterios minimos
  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Senha deve ter no minimo 6 caracteres';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um numero';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minuscula';
    }
    return null;
  }

  /// Signup com validacao completa
  Future<bool> signUp(String email, String password, String passwordConfirm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Validacao 1: Email vazio
    if (email.isEmpty) {
      _error = 'Email nao pode estar vazio';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validacao 2: Email valido
    if (!_isValidEmail(email)) {
      _error = 'Email invalido. Use um formato correto (ex: seu@email.com)';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validacao 3: Senha vazia
    if (password.isEmpty) {
      _error = 'Senha nao pode estar vazia';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validacao 4: Forca da senha
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      _error = passwordError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validacao 5: Confirmacao de senha
    if (password != passwordConfirm) {
      _error = 'Senhas nao conferem';
      _isLoading = false;
      notifyListeners();
      return false;
    }

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
      _error = 'Erro ao cadastrar: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login com validacao completa
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Validacao 1: Email vazio
    if (email.isEmpty) {
      _error = 'Email nao pode estar vazio';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validacao 2: Email valido
    if (!_isValidEmail(email)) {
      _error = 'Email invalido';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validacao 3: Senha vazia
    if (password.isEmpty) {
      _error = 'Senha nao pode estar vazia';
      _isLoading = false;
      notifyListeners();
      return false;
    }

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
      _error = 'Email ou senha incorretos. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao sair: ${e.toString()}';
      notifyListeners();
    }
  }
}
