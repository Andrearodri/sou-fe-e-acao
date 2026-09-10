import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client {
    _session = _supabase.auth.currentSession;
    _subscription = _supabase.auth.onAuthStateChange.listen(
      (data) {
        _session = data.session;
        _error = null;
        _notify();
      },
      onError: (Object error, StackTrace stackTrace) {
        _error = 'Não foi possível atualizar a sessão. Tente entrar novamente.';
        _notify();
      },
    );
  }

  final SupabaseClient _supabase;
  late final StreamSubscription<AuthState> _subscription;
  Session? _session;
  bool _isLoading = false;
  bool _disposed = false;
  String? _error;
  String? _message;

  User? get user => _session?.user;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get message => _message;

  bool _isValidEmail(String email) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email);

  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula.';
    }
    return null;
  }

  bool _start() {
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    _message = null;
    _notify();
    return true;
  }

  bool _reject(String message) {
    _error = message;
    _isLoading = false;
    _notify();
    return false;
  }

  Future<bool> signUp(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    if (!_start()) return false;
    email = email.trim();
    if (email.isEmpty) return _reject('E-mail não pode estar vazio.');
    if (!_isValidEmail(email)) return _reject('E-mail inválido.');
    if (password.isEmpty) return _reject('Senha não pode estar vazia.');
    final passwordError = _validatePassword(password);
    if (passwordError != null) return _reject(passwordError);
    if (password != passwordConfirm) return _reject('Senhas não conferem.');

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      // A returned user alone does not grant access when confirmation is pending.
      _session = response.session;
      if (_session == null) {
        _message = 'Se o cadastro puder ser concluído, você receberá um e-mail '
            'de confirmação. Verifique sua caixa de entrada antes de entrar.';
      }
      return true;
    } catch (_) {
      _error = 'Não foi possível concluir o cadastro. Verifique os dados '
          'e sua conexão e tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (!_start()) return false;
    email = email.trim();
    if (email.isEmpty) return _reject('E-mail não pode estar vazio.');
    if (!_isValidEmail(email)) return _reject('E-mail inválido.');
    if (password.isEmpty) return _reject('Senha não pode estar vazia.');

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _session = response.session;
      if (_session == null) {
        _error = 'Não foi possível iniciar uma sessão. Tente novamente.';
        return false;
      }
      return true;
    } catch (_) {
      _error = 'Não foi possível entrar. Verifique e-mail, senha, '
          'confirmação do cadastro e conexão.';
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> signOut() async {
    if (!_start()) return;
    try {
      await _supabase.auth.signOut();
      _session = null;
    } catch (_) {
      _error =
          'Não foi possível sair. Verifique sua conexão e tente novamente.';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void clearFeedback() {
    _error = null;
    _message = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
