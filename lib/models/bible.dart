class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.chapterCount,
  });

  final String id;
  final String name;
  final int chapterCount;
}

class BibleChapter {
  const BibleChapter({
    required this.book,
    required this.number,
    required this.verses,
  });

  final BibleBook book;
  final int number;
  final List<BibleVerse> verses;
}

class BibleVerse {
  const BibleVerse({required this.number, required this.text});

  final int number;
  final String text;
}
