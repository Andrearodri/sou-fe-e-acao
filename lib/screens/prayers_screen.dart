import 'dart:async';

import 'package:flutter/material.dart';

import '../models/prayer_entry.dart';
import '../repositories/local_prayer_repository.dart';
import '../repositories/prayer_repository.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({this.repository, super.key});

  final PrayerRepository? repository;

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  late final PrayerRepository _repository;
  List<PrayerEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalPrayerRepository();
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Abrindo seu espaço privado...'),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Orações', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Um espaço privado para registrar pedidos e reconhecer respostas.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Privado por padrão'),
                const SizedBox(height: 8),
                Text(
                  'Seus textos ficam somente neste dispositivo. Eles não são '
                  'enviados ao Supabase, à IA, a analytics ou a outros serviços.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'No Web, o armazenamento usa WebCrypto por meio de uma '
                  'biblioteca experimental e exige HTTPS ou localhost. Isso '
                  'não protege contra um navegador ou dispositivo comprometido.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (_error != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!),
            ),
          ),
        FilledButton.icon(
          onPressed: _error == null ? () => _editEntry() : null,
          icon: const Icon(Icons.add),
          label: const Text('Novo pedido de oração'),
        ),
        const SizedBox(height: 12),
        if (_entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.volunteer_activism_outlined, size: 44),
                  SizedBox(height: 12),
                  Text('Nenhum pedido registrado ainda.'),
                  SizedBox(height: 6),
                  Text(
                    'Quando quiser, escreva um pedido com calma. Você poderá '
                    'editar, excluir ou marcar como respondido.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          for (final entry in _entries)
            _PrayerCard(entry: entry, onAction: _action),
      ],
    );
  }

  Future<void> _load() async {
    try {
      final entries = await _repository.loadAll();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Não foi possível abrir o armazenamento privado neste navegador.';
      });
    }
  }

  Future<void> _action(_PrayerAction action, PrayerEntry entry) async {
    switch (action) {
      case _PrayerAction.edit:
        await _editEntry(entry);
      case _PrayerAction.delete:
        await _deleteEntry(entry);
      case _PrayerAction.toggleAnswered:
        await _toggleAnswered(entry);
    }
  }

  Future<void> _editEntry([PrayerEntry? existing]) async {
    final result = await showDialog<PrayerEntry>(
      context: context,
      builder: (_) => _PrayerFormDialog(existing: existing),
    );
    if (result == null) return;
    try {
      await _repository.save(result);
      if (!mounted) return;
      setState(() {
        final index = _entries.indexWhere((entry) => entry.id == result.id);
        if (index == -1) {
          _entries = [result, ..._entries];
        } else {
          _entries = [..._entries]..[index] = result;
        }
      });
    } catch (_) {
      _showStorageError();
    }
  }

  Future<void> _deleteEntry(PrayerEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir pedido?'),
        content: const Text('Esse texto será removido deste dispositivo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.delete(entry.id);
      if (!mounted) return;
      setState(() {
        _entries = _entries.where((item) => item.id != entry.id).toList();
      });
    } catch (_) {
      _showStorageError();
    }
  }

  Future<void> _toggleAnswered(PrayerEntry entry) async {
    final now = DateTime.now();
    final updated = entry.copyWith(
      updatedAt: now,
      isAnswered: !entry.isAnswered,
      answeredAt: entry.isAnswered ? null : now,
      clearAnsweredAt: entry.isAnswered,
    );
    try {
      await _repository.save(updated);
      if (!mounted) return;
      setState(() {
        _entries = _entries
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } catch (_) {
      _showStorageError();
    }
  }

  void _showStorageError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível salvar neste armazenamento privado.'),
      ),
    );
  }
}

enum _PrayerAction { edit, delete, toggleAnswered }

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({required this.entry, required this.onAction});

  final PrayerEntry entry;
  final Future<void> Function(_PrayerAction action, PrayerEntry entry) onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(entry.content,
                      maxLines: 4, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.isAnswered ? 'Respondido' : 'Em oração'} • ${_formatDate(entry.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<_PrayerAction>(
              tooltip: 'Ações do pedido',
              onSelected: (action) => onAction(action, entry),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _PrayerAction.toggleAnswered,
                  child: Text(entry.isAnswered
                      ? 'Marcar em oração'
                      : 'Marcar como respondido'),
                ),
                const PopupMenuItem(
                  value: _PrayerAction.edit,
                  child: Text('Editar'),
                ),
                const PopupMenuItem(
                  value: _PrayerAction.delete,
                  child: Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerFormDialog extends StatefulWidget {
  const _PrayerFormDialog({this.existing});

  final PrayerEntry? existing;

  @override
  State<_PrayerFormDialog> createState() => _PrayerFormDialogState();
}

class _PrayerFormDialogState extends State<_PrayerFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title);
    _contentController = TextEditingController(text: widget.existing?.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Novo pedido' : 'Editar pedido'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe um título.'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLength: 1200,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Pedido'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escreva seu pedido.'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final existing = widget.existing;
    Navigator.of(context).pop(
      PrayerEntry(
        id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        answeredAt: existing?.answeredAt,
        isAnswered: existing?.isAnswered ?? false,
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
