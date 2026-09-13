import '../models/bible.dart';

class LocalBibleBookData {
  const LocalBibleBookData({required this.book, required this.chapters});

  final BibleBook book;
  final Map<int, List<BibleVerse>> chapters;
}

const localBibleAttribution =
    'Bíblia Livre (BLIVRE), Copyright © Diego Santos, Mario Sérgio e Marco Teles. '
    'Versão do repositório oficial blivre/BibliaLivre, revisão 2025.1.0 '
    '(commit a315a15, 12/01/2025). Licença Creative Commons Atribuição 3.0 Brasil.';
