import '../models/biblical_message.dart';
import 'local_bible_proverbios.dart';
import 'local_bible_salmos.dart';
import '../models/bible.dart';

String _verse(List<BibleVerse> verses, int number) =>
    verses.firstWhere((verse) => verse.number == number).text;

// Small offline catalogue derived from the BLIVRE pilot already attributed in
// THIRD_PARTY_NOTICES.md. The production table can add reviewed messages later.
final localMessages = <BiblicalMessage>[
  BiblicalMessage(
    slug: 'confiar-de-todo-coracao',
    text: _verse(localBibleProverbios[3]!, 5),
    reference: 'Provérbios 3:5',
    category: 'Fé',
    featured: true,
    displayOrder: 1,
  ),
  BiblicalMessage(
    slug: 'caminhos-endireitados',
    text: _verse(localBibleProverbios[3]!, 6),
    reference: 'Provérbios 3:6',
    category: 'Promessas',
    displayOrder: 2,
  ),
  BiblicalMessage(
    slug: 'o-senhor-me-sustenta',
    text: _verse(localBibleSalmos[3]!, 5),
    reference: 'Salmos 3:5',
    category: 'Força',
    featured: true,
    displayOrder: 3,
  ),
  BiblicalMessage(
    slug: 'escudo-e-gloria',
    text: _verse(localBibleSalmos[3]!, 3),
    reference: 'Salmos 3:3',
    category: 'Esperança',
    displayOrder: 4,
  ),
  BiblicalMessage(
    slug: 'clamo-e-ele-responde',
    text: _verse(localBibleSalmos[3]!, 4),
    reference: 'Salmos 3:4',
    category: 'Oração',
    displayOrder: 5,
  ),
  BiblicalMessage(
    slug: 'medita-de-dia-e-noite',
    text: _verse(localBibleSalmos[1]!, 2),
    reference: 'Salmos 1:2',
    category: 'Salmos',
    displayOrder: 6,
  ),
  BiblicalMessage(
    slug: 'arvore-junto-as-aguas',
    text: _verse(localBibleSalmos[1]!, 3),
    reference: 'Salmos 1:3',
    category: 'Motivação',
    displayOrder: 7,
  ),
  BiblicalMessage(
    slug: 'bondade-e-fidelidade',
    text: _verse(localBibleProverbios[3]!, 3),
    reference: 'Provérbios 3:3',
    category: 'Amor',
    displayOrder: 8,
  ),
  BiblicalMessage(
    slug: 'alegria-no-coracao',
    text: _verse(localBibleSalmos[4]!, 7),
    reference: 'Salmos 4:7',
    category: 'Gratidão',
    displayOrder: 9,
  ),
  BiblicalMessage(
    slug: 'instrucao-de-teu-pai',
    text: _verse(localBibleProverbios[1]!, 8),
    reference: 'Provérbios 1:8',
    category: 'Família',
    displayOrder: 10,
  ),
  BiblicalMessage(
    slug: 'paz-ao-deitar',
    text: _verse(localBibleSalmos[4]!, 8),
    reference: 'Salmos 4:8',
    category: 'Ansiedade',
    displayOrder: 11,
  ),
  BiblicalMessage(
    slug: 'ajuda-ao-proximo',
    text: _verse(localBibleProverbios[3]!, 27),
    reference: 'Provérbios 3:27',
    category: 'Amizade',
    displayOrder: 12,
  ),
];
