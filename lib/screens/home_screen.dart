import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vida com Cristo'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: auth.isLoading ? null : () => auth.signOut(),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.book_outlined, size: 56, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo ao Vida com Cristo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sua conta está conectada. Os conteúdos abaixo estão em '
                'preparação e ainda não estão disponíveis.',
                textAlign: TextAlign.center,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(auth.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              ],
              const SizedBox(height: 24),
              _buildCard('Bíblia', Icons.book_outlined),
              _buildCard('Devocional', Icons.calendar_today_outlined),
              _buildCard('Orações', Icons.favorite_border),
              _buildCard('Comunidade', Icons.people_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: const Text('Em breve'),
        enabled: false,
      ),
    );
  }
}
