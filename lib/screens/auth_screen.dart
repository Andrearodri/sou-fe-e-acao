import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Vida com Cristo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isSignUp ? 'Criar conta' : 'Entrar',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Uma plataforma de fé em construção.'),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    enabled: !auth.isLoading,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    enabled: !auth.isLoading,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: [
                      _isSignUp
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    textInputAction:
                        _isSignUp ? TextInputAction.next : TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isSignUp && !auth.isLoading) _handleAuth();
                    },
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      helperText: _isSignUp
                          ? 'Mínimo de 6 caracteres, uma letra minúscula e um número.'
                          : null,
                      helperMaxLines: 3,
                    ),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordConfirmController,
                      enabled: !auth.isLoading,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!auth.isLoading) _handleAuth();
                      },
                      decoration:
                          const InputDecoration(labelText: 'Confirmar senha'),
                    ),
                  ],
                  if (auth.error != null || auth.message != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        auth.error ?? auth.message!,
                        style: TextStyle(
                          color: auth.error != null
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleAuth,
                    child: Text(auth.isLoading
                        ? 'Aguarde…'
                        : (_isSignUp ? 'Criar conta' : 'Entrar')),
                  ),
                  TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            auth.clearFeedback();
                            _passwordController.clear();
                            _passwordConfirmController.clear();
                            setState(() => _isSignUp = !_isSignUp);
                          },
                    child: Text(_isSignUp
                        ? 'Já tem conta? Entrar'
                        : 'Não tem conta? Criar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    final auth = context.read<AuthProvider>();
    final success = _isSignUp
        ? await auth.signUp(
            _emailController.text,
            _passwordController.text,
            _passwordConfirmController.text,
          )
        : await auth.signIn(_emailController.text, _passwordController.text);
    if (success && mounted) {
      _passwordController.clear();
      _passwordConfirmController.clear();
      if (!auth.isAuthenticated) setState(() => _isSignUp = false);
    }
  }
}
