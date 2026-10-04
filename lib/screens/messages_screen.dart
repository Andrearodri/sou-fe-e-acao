import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/local_bible_data.dart';
import '../models/biblical_message.dart';
import '../providers/auth_provider.dart';
import '../repositories/message_favorite_repository.dart';
import '../repositories/message_repository.dart';
import '../services/message_share_service.dart';
import 'message_card.dart';
import 'message_image_composer.dart';

const messageCategories = <String>[
  'Fé',
  'Esperança',
  'Força',
  'Amor',
  'Gratidão',
  'Ansiedade',
  'Família',
  'Amizade',
  'Oração',
  'Motivação',
  'Promessas',
  'Salmos',
];

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    required this.repository,
    required this.favorites,
    super.key,
  });
  final MessageRepository repository;
  final MessageFavoriteRepository favorites;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<BiblicalMessage> _items = [];
  Set<String> _favoriteIds = {};
  String? _category;
  String? _userId;
  bool _favoritesLoaded = false;
  bool _favoritesOnly = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _offline = false;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(reset: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthProvider>().user?.id;
    if (!_favoritesLoaded || _userId != userId) {
      _userId = userId;
      _favoritesLoaded = true;
      _loadFavorites();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _feedback(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await widget.favorites.load(_userId);
      if (mounted) {
        setState(() => _favoriteIds = ids);
        if (_favoritesOnly) _load(reset: true);
      }
    } catch (_) {
      if (mounted) {
        _feedback(
          'Não foi possível carregar seus favoritos. Verifique a conexão ou entre novamente.',
        );
      }
    }
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loadingMore || !_hasMore)) return;
    final generation = reset ? ++_generation : _generation;
    setState(() {
      if (reset) {
        _loading = true;
        _items = [];
        _error = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final page = await widget.repository.load(
        query: _search.text,
        category: _category,
        favoriteSlugs: _favoritesOnly ? _favoriteIds : null,
        offset: reset ? 0 : _items.length,
      );
      if (!mounted || generation != _generation) return;
      if (page.offline && !reset) {
        _load(reset: true);
        return;
      }
      setState(() {
        _items = [..._items, ...page.items];
        _hasMore = page.hasMore;
        _offline = page.offline;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error =
            'Não foi possível carregar as mensagens. Verifique a conexão e tente novamente.';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _toggleFavorite(BiblicalMessage message) async {
    final current = _favoriteIds.contains(message.slug);
    try {
      final next = await widget.favorites.toggle(
        message.slug,
        userId: _userId,
        currentlyFavorite: current,
      );
      if (!mounted) return;
      setState(() {
        if (next) {
          _favoriteIds.add(message.slug);
        } else {
          _favoriteIds.remove(message.slug);
        }
      });
      _feedback(
        next
            ? 'Mensagem adicionada aos favoritos.'
            : 'Mensagem removida dos favoritos.',
      );
      if (_favoritesOnly) _load(reset: true);
    } catch (_) {
      if (mounted) {
        _feedback(
          'Não foi possível alterar o favorito. Verifique a conexão ou entre novamente.',
        );
      }
    }
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String success,
    String failure,
  ) async {
    try {
      await action();
      if (mounted) _feedback(success);
    } catch (_) {
      if (mounted) _feedback(failure);
    }
  }

  Future<void> _open(BiblicalMessage message) async {
    await Navigator.of(context).pushNamed('/mensagens/${message.slug}');
    if (mounted) _loadFavorites();
  }

  void _compose(BiblicalMessage message) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MessageImageComposer(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const share = MessageShareService();
    final visible = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagens')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(
                'Palavras para guardar e compartilhar',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Versículos do acervo piloto da Bíblia Livre para fortalecer sua caminhada.',
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Buscar texto ou referência',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          onPressed: () {
                            _search.clear();
                            _load(reset: true);
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) {
                  setState(() {});
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 350),
                    () => _load(reset: true),
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownMenu<String>(
                    key: ValueKey(_category),
                    label: const Text('Categoria'),
                    initialSelection: '',
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(value: '', label: 'Todas'),
                      ...messageCategories.map(
                        (category) =>
                            DropdownMenuEntry(value: category, label: category),
                      ),
                    ],
                    onSelected: (value) {
                      setState(() => _category = value == '' ? null : value);
                      _load(reset: true);
                    },
                  ),
                  FilterChip(
                    label: const Text('Favoritas'),
                    avatar: const Icon(Icons.favorite_border, size: 18),
                    selected: _favoritesOnly,
                    onSelected: (value) {
                      setState(() => _favoritesOnly = value);
                      _load(reset: true);
                    },
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _search.clear();
                      setState(() {
                        _category = null;
                        _favoritesOnly = false;
                      });
                      _load(reset: true);
                    },
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Limpar filtros'),
                  ),
                ],
              ),
              if (_offline)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'Exibindo o acervo disponível neste dispositivo.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () => _load(reset: true),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              else if (visible.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _items.isEmpty &&
                              _search.text.isEmpty &&
                              _category == null
                          ? 'Ainda não há mensagens publicadas.'
                          : 'Nenhuma mensagem encontrada. Ajuste os filtros.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final twoColumns = constraints.maxWidth >= 780;
                    final width = twoColumns
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 0,
                      children: [
                        for (final message in visible)
                          SizedBox(
                            width: width,
                            child: MessageCard(
                              message: message,
                              isFavorite: _favoriteIds.contains(message.slug),
                              onOpen: () => _open(message),
                              onCreateImage: () => _compose(message),
                              onWhatsapp: () => _runAction(
                                () => share.whatsapp(message),
                                'WhatsApp aberto.',
                                'Não foi possível abrir o WhatsApp.',
                              ),
                              onShare: () async {
                                try {
                                  final native = await share.share(message);
                                  if (context.mounted) {
                                    _feedback(
                                      native
                                          ? 'Compartilhamento aberto.'
                                          : 'Compartilhamento indisponível; mensagem copiada.',
                                    );
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    _feedback(
                                      'Não foi possível compartilhar ou copiar a mensagem.',
                                    );
                                  }
                                }
                              },
                              onCopy: () => _runAction(
                                () => share.copy(message),
                                'Mensagem copiada',
                                'Não foi possível copiar a mensagem.',
                              ),
                              onFavorite: () => _toggleFavorite(message),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              if (_hasMore)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _loadingMore ? null : () => _load(reset: false),
                    icon: _loadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more),
                    label: Text(_loadingMore ? 'Carregando' : 'Carregar mais'),
                  ),
                ),
              if (!_hasMore && _items.isNotEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Você chegou ao fim das mensagens.'),
                  ),
                ),
              const SizedBox(height: 22),
              Text(
                localBibleAttribution,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageDetailsScreen extends StatefulWidget {
  const MessageDetailsScreen({
    required this.slug,
    required this.repository,
    required this.favorites,
    super.key,
  });
  final String slug;
  final MessageRepository repository;
  final MessageFavoriteRepository favorites;

  @override
  State<MessageDetailsScreen> createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  BiblicalMessage? _message;
  bool _loading = true;
  bool _favorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final message = await widget.repository.bySlug(widget.slug);
      if (!mounted) return;
      final userId = context.read<AuthProvider>().user?.id;
      Set<String> favorites = {};
      try {
        favorites = await widget.favorites.load(userId);
      } catch (_) {
        // Reading a public message must not depend on favorites availability.
      }
      if (mounted) {
        setState(() {
          _message = message;
          _favorite = favorites.contains(widget.slug);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível abrir a mensagem. Tente novamente.';
          _loading = false;
        });
      }
    }
  }

  void _feedback(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _action(
    Future<void> Function() action,
    String success,
    String failure,
  ) async {
    try {
      await action();
      if (mounted) _feedback(success);
    } catch (_) {
      if (mounted) _feedback(failure);
    }
  }

  Future<void> _toggle() async {
    try {
      final next = await widget.favorites.toggle(
        widget.slug,
        userId: context.read<AuthProvider>().user?.id,
        currentlyFavorite: _favorite,
      );
      if (mounted) {
        setState(() => _favorite = next);
        _feedback(
          next
              ? 'Mensagem adicionada aos favoritos.'
              : 'Mensagem removida dos favoritos.',
        );
      }
    } catch (_) {
      if (mounted) {
        _feedback(
          'Não foi possível alterar o favorito. Verifique a conexão ou entre novamente.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    const share = MessageShareService();
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagem bíblica')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Column(
                  children: [
                    Text(_error!),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                )
              else if (message == null)
                const Text('Mensagem não encontrada.')
              else ...[
                MessageCard(
                  message: message,
                  isFavorite: _favorite,
                  onOpen: null,
                  onCreateImage: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MessageImageComposer(message: message),
                    ),
                  ),
                  onWhatsapp: () => _action(
                    () => share.whatsapp(message),
                    'WhatsApp aberto.',
                    'Não foi possível abrir o WhatsApp.',
                  ),
                  onShare: () async {
                    try {
                      final native = await share.share(message);
                      if (context.mounted) {
                        _feedback(
                          native
                              ? 'Compartilhamento aberto.'
                              : 'Compartilhamento indisponível; mensagem copiada.',
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        _feedback('Não foi possível compartilhar ou copiar.');
                      }
                    }
                  },
                  onCopy: () => _action(
                    () => share.copy(message),
                    'Mensagem copiada',
                    'Não foi possível copiar a mensagem.',
                  ),
                  onFavorite: _toggle,
                ),
                const SizedBox(height: 12),
                Text(
                  localBibleAttribution,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
