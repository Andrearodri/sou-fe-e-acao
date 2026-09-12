import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({this.onThemeModeChanged, super.key});
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Mais', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Preferências e acesso à sua conta',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.person_outline,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              auth.isAuthenticated
                                  ? 'Conta conectada'
                                  : 'Modo visitante',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            auth.isAuthenticated
                                ? 'A sincronização será apresentada em uma etapa futura.'
                                : 'Você pode começar sem criar uma conta.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (auth.isAuthenticated)
                  OutlinedButton.icon(
                    onPressed: auth.isLoading ? null : auth.signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da conta'),
                  )
                else
                  FilledButton.icon(
                    onPressed: auth.isAvailable
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const AuthScreen()),
                            )
                        : null,
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar ou criar conta'),
                  ),
                if (!auth.isAvailable) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Auth indisponível nesta execução; o conteúdo público continua acessível.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text('Aparência'),
                subtitle: Text('Escolha o tema para esta sessão'),
              ),
              RadioGroup<ThemeMode>(
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) onThemeModeChanged?.call(mode);
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text('Claro'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text('Escuro'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre o Vida com Cristo'),
            subtitle: Text(
                'Uma experiência acolhedora para cultivar leitura, oração e vida cristã prática.'),
          ),
        ),
      ],
    );
  }
}
