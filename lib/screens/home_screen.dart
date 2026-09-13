import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/bible.dart';
import '../models/devotional.dart';
import '../providers/local_settings_provider.dart';
import '../providers/today_provider.dart';
import '../repositories/bible_repository.dart';
import '../repositories/devotional_repository.dart';
import '../repositories/local_bible_repository.dart';
import '../repositories/local_devotional_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.bibleRepository,
    this.devotionalRepository,
    this.onOpenBible,
    super.key,
  });

  final BibleRepository? bibleRepository;
  final DevotionalRepository? devotionalRepository;
  final VoidCallback? onOpenBible;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final BibleRepository _bibleRepository;
  late final DevotionalRepository _devotionalRepository;
  late final Future<_DailyContent> _contentFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted && !_contentFutureInitialized) {
      _bibleRepository = widget.bibleRepository ?? LocalBibleRepository();
      _devotionalRepository =
          widget.devotionalRepository ?? LocalDevotionalRepository();
      _contentFuture = _loadContent(context.read<TodayProvider>().now);
      _contentFutureInitialized = true;
    }
  }

  bool _contentFutureInitialized = false;

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TodayProvider>();
    final settings = context.watch<LocalSettingsProvider?>();
    final now = today.now;
    final greeting = now.hour < 12
        ? 'Bom dia'
        : now.hour < 18
            ? 'Boa tarde'
            : 'Boa noite';
    final displayName = settings?.displayName.trim() ?? '';
    final greetingLabel =
        displayName.isEmpty ? '$greeting 👋' : '$greeting, $displayName 👋';
    final editorialFontScale = settings?.editorialFontScale ?? 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(greetingLabel, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          _formatPortugueseDate(now),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        _ProgressCard(today: today),
        FutureBuilder<_DailyContent>(
          future: _contentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'O conteúdo local de hoje não está disponível nesta execução.',
                  ),
                ),
              );
            }
            final content = snapshot.data!;
            return _DailyContentCards(
              content: content,
              fontScale: editorialFontScale,
              onOpenBible: widget.onOpenBible,
            );
          },
        ),
        _RoutineCard(today: today),
      ],
    );
  }

  Future<_DailyContent> _loadContent(DateTime date) async {
    final devotional = await _devotionalRepository.forDate(date);
    if (devotional == null) return const _DailyContent();
    final chapter = await _bibleRepository.loadChapter(
      bookId: devotional.bookId,
      chapterNumber: devotional.chapterNumber,
    );
    final verse = chapter?.verses
        .where((item) => item.number == devotional.verseNumber)
        .firstOrNull;
    return _DailyContent(devotional: devotional, verse: verse);
  }
}

class _DailyContent {
  const _DailyContent({this.devotional, this.verse});

  final Devotional? devotional;
  final BibleVerse? verse;
}

class _DailyContentCards extends StatelessWidget {
  const _DailyContentCards({
    required this.content,
    required this.fontScale,
    required this.onOpenBible,
  });

  final _DailyContent content;
  final double fontScale;
  final VoidCallback? onOpenBible;

  @override
  Widget build(BuildContext context) {
    final devotional = content.devotional;
    final verse = content.verse;
    if (devotional == null || verse == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('O conteúdo local de hoje está em preparação.'),
        ),
      );
    }
    final editorialStyle = GoogleFonts.merriweather(
      textStyle: Theme.of(context).textTheme.bodyLarge,
      height: 1.65,
      fontSize:
          (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) * fontScale,
    );
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow(
                  icon: Icons.format_quote_outlined,
                  text: 'VERSÍCULO PROVISÓRIO • ${devotional.verseReference}',
                ),
                const SizedBox(height: 14),
                Text(
                  '“${verse.text}”',
                  style: editorialStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tradução BLIVRE • texto local piloto',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow(
                  icon: Icons.auto_stories_outlined,
                  text: 'DEVOCIONAL PROVISÓRIO • REVISÃO HUMANA PENDENTE',
                ),
                const SizedBox(height: 14),
                Text(
                  devotional.title,
                  style: GoogleFonts.merriweather(
                    textStyle: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 10),
                Text(devotional.reflection, style: editorialStyle),
                const SizedBox(height: 14),
                Text('Para praticar',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(devotional.application, style: editorialStyle),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Ler capítulo',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  devotional.bibleReference,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onOpenBible,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Abrir Bíblia'),
                ),
              ],
            ),
          ),
        ),
        if (devotional.prayer case final prayer?)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oração curta para hoje',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Text(prayer, style: editorialStyle),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.today});

  final TodayProvider today;

  @override
  Widget build(BuildContext context) {
    final progress = today.completedDays / 7;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Seu ritmo nesta semana',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(width: 12),
                Text('${today.completedDays} de 7 dias',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: .75),
              ),
            ),
            const SizedBox(height: 10),
            Text('Acolhimento, retorno e consistência.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.today});

  final TodayProvider today;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Concluir dia',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              today.completedToday
                  ? 'Você já concluiu a rotina de hoje. Cada dia conta.'
                  : 'Quando terminar, registre este momento como concluído.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  today.completedToday ? null : () => today.completeToday(),
              icon: Icon(today.completedToday
                  ? Icons.check_circle_outline
                  : Icons.check),
              label: Text(today.completedToday
                  ? 'Rotina concluída hoje'
                  : 'Concluir rotina de hoje'),
            ),
            const SizedBox(height: 10),
            Text(
              'Modo visitante: o progresso fica salvo somente neste dispositivo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPortugueseDate(DateTime date) {
  const weekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}
