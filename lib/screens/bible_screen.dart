import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../content/local_bible_data.dart';
import '../models/bible.dart';
import '../providers/local_settings_provider.dart';
import '../repositories/bible_repository.dart';
import '../repositories/local_bible_repository.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({this.repository, super.key});

  final BibleRepository? repository;

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  late final BibleRepository _repository;
  late final Future<List<BibleBook>> _booksFuture;
  String _selectedBookId = 'joao';
  int _selectedChapter = 1;
  late Future<BibleChapter?> _chapterFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalBibleRepository();
    _booksFuture = _repository.loadBooks();
    _chapterFuture = _repository.loadChapter(
      bookId: _selectedBookId,
      chapterNumber: _selectedChapter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LocalSettingsProvider>();
    return FutureBuilder<List<BibleBook>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        final books = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || books == null || books.isEmpty) {
          return const _BibleMessage(
            title: 'Bíblia indisponível',
            message: 'Não foi possível carregar a biblioteca local agora.',
          );
        }
        final selectedBook = books.firstWhere(
          (book) => book.id == _selectedBookId,
          orElse: () => books.first,
        );
        final chapter = _selectedChapter.clamp(1, selectedBook.chapterCount);
        if (selectedBook.id != _selectedBookId || chapter != _selectedChapter) {
          _selectedBookId = selectedBook.id;
          _selectedChapter = chapter;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text('Bíblia', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Leitura local, sem depender de uma API externa.',
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
                    DropdownButtonFormField<String>(
                      initialValue: selectedBook.id,
                      decoration: const InputDecoration(labelText: 'Livro'),
                      items: [
                        for (final book in books)
                          DropdownMenuItem(
                            value: book.id,
                            child: Text(book.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedBookId = value;
                          _selectedChapter = 1;
                          _chapterFuture = _repository.loadChapter(
                            bookId: value,
                            chapterNumber: 1,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: chapter,
                      decoration: const InputDecoration(labelText: 'Capítulo'),
                      items: [
                        for (var number = 1;
                            number <= selectedBook.chapterCount;
                            number++)
                          DropdownMenuItem(
                            value: number,
                            child: Text('Capítulo $number'),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedChapter = value;
                          _chapterFuture = _repository.loadChapter(
                            bookId: _selectedBookId,
                            chapterNumber: value,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BLIVRE • texto local piloto',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localBibleAttribution,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            FutureBuilder<BibleChapter?>(
              future: _chapterFuture,
              builder: (context, chapterSnapshot) {
                if (chapterSnapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final loadedChapter = chapterSnapshot.data;
                if (chapterSnapshot.hasError || loadedChapter == null) {
                  return const _BibleMessage(
                    title: 'Capítulo indisponível',
                    message:
                        'Este capítulo não está disponível no piloto local.',
                  );
                }
                return _ChapterReader(
                  chapter: loadedChapter,
                  fontScale: settings.editorialFontScale,
                  onPrevious: loadedChapter.number > 1
                      ? () => _changeChapter(loadedChapter.number - 1)
                      : null,
                  onNext: loadedChapter.number < selectedBook.chapterCount
                      ? () => _changeChapter(loadedChapter.number + 1)
                      : null,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _changeChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _chapterFuture = _repository.loadChapter(
        bookId: _selectedBookId,
        chapterNumber: chapter,
      );
    });
  }
}

class _ChapterReader extends StatelessWidget {
  const _ChapterReader({
    required this.chapter,
    required this.fontScale,
    required this.onPrevious,
    required this.onNext,
  });

  final BibleChapter chapter;
  final double fontScale;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.merriweather(
      textStyle: Theme.of(context).textTheme.bodyLarge,
      height: 1.8,
    );
    final verseStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * fontScale,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${chapter.book.name} ${chapter.number}',
              style: GoogleFonts.merriweather(
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),
            for (final verse in chapter.verses)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RichText(
                  text: TextSpan(
                    style: verseStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: '${verse.number} ',
                        style: verseStyle.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: verse.text),
                    ],
                  ),
                ),
              ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Próximo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BibleMessage extends StatelessWidget {
  const _BibleMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 48),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
