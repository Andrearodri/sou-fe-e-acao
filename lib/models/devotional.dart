enum EditorialStatus { draft, reviewRequired, approved }

class Devotional {
  const Devotional({
    required this.id,
    required this.title,
    required this.bibleReference,
    required this.verseReference,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.reflection,
    required this.application,
    required this.prayer,
    required this.status,
  });

  final String id;
  final String title;
  final String bibleReference;
  final String verseReference;
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final String reflection;
  final String application;
  final String? prayer;
  final EditorialStatus status;
}
