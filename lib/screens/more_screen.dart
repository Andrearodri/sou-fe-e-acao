import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/local_settings.dart';
import '../providers/auth_provider.dart';
import '../providers/local_settings_provider.dart';
import '../providers/today_provider.dart';
import 'auth_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _displayNameController = TextEditingController();
  String _syncedDisplayName = '';

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<LocalSettingsProvider>();
    final today = context.read<TodayProvider>();
    _syncDisplayName(settings.displayName);

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
        _ProfileCard(
          controller: _displayNameController,
          onSave: () => _saveDisplayName(settings),
        ),
        _AccountCard(auth: auth),
        _AppearanceCard(settings: settings),
        _LocalDataCard(
          onClear: () => _confirmClearLocalData(settings, today),
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

  void _syncDisplayName(String displayName) {
    if (displayName == _syncedDisplayName) return;
    _displayNameController.value = TextEditingValue(
      text: displayName,
      selection: TextSelection.collapsed(offset: displayName.length),
    );
    _syncedDisplayName = displayName;
  }

  Future<void> _saveDisplayName(LocalSettingsProvider settings) async {
    await settings.setDisplayName(_displayNameController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nome salvo neste dispositivo.')),
    );
  }

  Future<void> _confirmClearLocalData(
    LocalSettingsProvider settings,
    TodayProvider today,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar dados locais?'),
        content: const Text(
          'Isso remove nome, preferências e progresso deste dispositivo. '
          'Sua conta não será excluída nem desconectada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Limpar dados'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await Future.wait([settings.clear(), today.clear()]);
    _displayNameController.clear();
    _syncedDisplayName = '';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados locais removidos.')),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller, required this.onSave});

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Perfil', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Como você gostaria que eu te chamasse? Isso é opcional.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLength: 48,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSave(),
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex.: Ana',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar nome'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.auth});

  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.settings});

  final LocalSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Aparência'),
            subtitle: Text('Escolha o tema e o tamanho do conteúdo editorial'),
          ),
          RadioGroup<AppThemePreference>(
            groupValue: settings.themePreference,
            onChanged: (value) {
              if (value != null) unawaited(settings.setThemePreference(value));
            },
            child: const Column(
              children: [
                RadioListTile<AppThemePreference>(
                  value: AppThemePreference.system,
                  title: Text('Usar sistema'),
                ),
                RadioListTile<AppThemePreference>(
                  value: AppThemePreference.light,
                  title: Text('Claro'),
                ),
                RadioListTile<AppThemePreference>(
                  value: AppThemePreference.dark,
                  title: Text('Escuro'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.format_size_outlined),
            title: Text('Tamanho do texto editorial'),
          ),
          RadioGroup<EditorialFontSize>(
            groupValue: settings.editorialFontSize,
            onChanged: (value) {
              if (value != null) {
                unawaited(settings.setEditorialFontSize(value));
              }
            },
            child: const Column(
              children: [
                RadioListTile<EditorialFontSize>(
                  value: EditorialFontSize.small,
                  title: Text('Menor'),
                ),
                RadioListTile<EditorialFontSize>(
                  value: EditorialFontSize.standard,
                  title: Text('Padrão'),
                ),
                RadioListTile<EditorialFontSize>(
                  value: EditorialFontSize.large,
                  title: Text('Maior'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalDataCard extends StatelessWidget {
  const _LocalDataCard({required this.onClear});

  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Dados locais',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Nome, preferências e progresso ficam somente neste dispositivo até uma futura sincronização.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Limpar dados locais'),
            ),
          ],
        ),
      ),
    );
  }
}
