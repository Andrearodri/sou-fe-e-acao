import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vida com Cristo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              _isSignUp ? 'Criar Conta' : 'Entrar',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 30),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => ElevatedButton(
                onPressed: auth.isLoading ? null : _handleAuth,
                child: Text(_isSignUp ? 'Criar Conta' : 'Entrar'),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'Já tem conta? Entrar'
                    : 'Não tem conta? Criar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAuth() async {
    final auth = context.read<AuthProvider>();
    final success = _isSignUp
        ? await auth.signUp(_emailController.text, _passwordController.text)
        : await auth.signIn(_emailController.text, _passwordController.text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Erro desconhecido')),
      );
    }
  }
}
