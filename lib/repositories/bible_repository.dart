import '../models/bible.dart';

abstract interface class BibleRepository {
  Future<List<BibleBook>> loadBooks();

  Future<BibleChapter?> loadChapter({
    required String bookId,
    required int chapterNumber,
  });
}
