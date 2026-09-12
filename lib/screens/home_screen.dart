import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../content/preview_content.dart';
import '../providers/local_settings_provider.dart';
import '../providers/today_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final formattedDate = _formatPortugueseDate(now);
    final displayName = settings?.displayName.trim() ?? '';
    final greetingLabel =
        displayName.isEmpty ? '$greeting 👋' : '$greeting, $displayName 👋';
    final editorialFontScale = settings?.editorialFontScale ?? 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(greetingLabel, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(formattedDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
        const SizedBox(height: 24),
        _ProgressCard(today: today),
        _EditorialCard(
          eyebrow: 'DEVOCIONAL PROVISÓRIO',
          icon: Icons.auto_stories_outlined,
          title: PreviewContent.devotionalTitle,
          body: PreviewContent.devotionalBody,
          fontFamily: GoogleFonts.merriweather().fontFamily,
          fontScale: editorialFontScale,
        ),
        _EditorialCard(
          eyebrow: 'VERSÍCULO PROVISÓRIO',
          icon: Icons.format_quote_outlined,
          title: 'Versículo do dia',
          body: PreviewContent.verseBody,
          fontFamily: GoogleFonts.merriweather().fontFamily,
          fontScale: editorialFontScale,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Sua rotina de hoje',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  today.completedToday
                      ? 'Você já concluiu a rotina de hoje. Cada dia conta.'
                      : 'Reserve alguns minutos para estar presente hoje.',
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
        ),
      ],
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

class _EditorialCard extends StatelessWidget {
  const _EditorialCard({
    required this.eyebrow,
    required this.icon,
    required this.title,
    required this.body,
    required this.fontFamily,
    required this.fontScale,
  });

  final String eyebrow;
  final IconData icon;
  final String title;
  final String body;
  final String? fontFamily;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(eyebrow,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          )),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: _editorialStyle(
                Theme.of(context).textTheme.titleLarge,
                fontFamily,
                fontScale,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: _editorialStyle(
                Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                fontFamily,
                fontScale,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Conteúdo de demonstração aguardando revisão editorial.',
              style: _editorialStyle(
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                fontFamily,
                fontScale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle? _editorialStyle(
  TextStyle? style,
  String? fontFamily,
  double scale,
) {
  final fontSize = style?.fontSize;
  return style?.copyWith(
    fontFamily: fontFamily,
    fontSize: fontSize == null ? null : fontSize * scale,
  );
}
