import '../content/local_bible_joao.dart';
import '../content/local_bible_proverbios.dart';
import '../content/local_bible_salmos.dart';
import '../models/bible.dart';
import 'bible_repository.dart';

class LocalBibleRepository implements BibleRepository {
  static const _books = <BibleBook>[
    BibleBook(id: 'joao', name: 'João', chapterCount: 3),
    BibleBook(id: 'salmos', name: 'Salmos', chapterCount: 5),
    BibleBook(id: 'proverbios', name: 'Provérbios', chapterCount: 3),
  ];

  static const _chapters = <String, Map<int, List<BibleVerse>>>{
    'joao': <int, List<BibleVerse>>{
      ...localBibleJoao,
    },
    'salmos': <int, List<BibleVerse>>{
      ...localBibleSalmos,
    },
    'proverbios': <int, List<BibleVerse>>{
      ...localBibleProverbios,
    },
  };

  @override
  Future<List<BibleBook>> loadBooks() async => _books;

  @override
  Future<BibleChapter?> loadChapter({
    required String bookId,
    required int chapterNumber,
  }) async {
    for (final book in _books) {
      if (book.id != bookId) continue;
      final verses = _chapters[bookId]?[chapterNumber];
      if (verses == null) return null;
      return BibleChapter(
        book: book,
        number: chapterNumber,
        verses: verses,
      );
    }
    return null;
  }
}
