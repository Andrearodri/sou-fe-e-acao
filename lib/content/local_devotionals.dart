import '../models/devotional.dart';

const localDevotionals = <Devotional>[
  Devotional(
    id: 'daily-01',
    title: 'Um passo de cada vez',
    bibleReference: 'João 1:1–5',
    verseReference: 'João 1:1',
    bookId: 'joao',
    chapterNumber: 1,
    verseNumber: 1,
    reflection:
        'A vida de fé começa reconhecendo quem Cristo é. Antes de qualquer '
        'tarefa ou resposta, existe a presença do Filho, a Palavra que estava '
        'com Deus e é Deus. Hoje, você não precisa resolver tudo de uma vez; '
        'pode caminhar com confiança no próximo passo.',
    application:
        'Separe alguns minutos para ler João 1 e anote uma verdade sobre '
        'Jesus que deseja levar para o seu dia.',
    prayer:
        'Senhor Deus, firma meus passos em Cristo e ensina-me a caminhar com '
        'confiança hoje. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
  Devotional(
    id: 'daily-02',
    title: 'Esperança para a alma',
    bibleReference: 'Salmos 5:1–12',
    verseReference: 'Salmos 5:2',
    bookId: 'salmos',
    chapterNumber: 5,
    verseNumber: 2,
    reflection:
        'Há dias em que precisamos começar de novo diante de Deus. A Escritura '
        'nos ensina a falar com honestidade e a buscar o Senhor logo cedo. A '
        'esperança cristã não depende de negar a dor, mas de lembrar que Deus '
        'continua sendo digno de confiança.',
    application:
        'Separe alguns minutos para apresentar a Deus, com honestidade, aquilo '
        'que pesa no seu coração.',
    prayer:
        'Deus de esperança, recebe meu coração abatido e ajuda-me a esperar em '
        'ti com sinceridade. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
  Devotional(
    id: 'daily-03',
    title: 'Sabedoria para o caminho',
    bibleReference: 'Provérbios 3:1–8',
    verseReference: 'Provérbios 3:5–6',
    bookId: 'proverbios',
    chapterNumber: 3,
    verseNumber: 5,
    reflection:
        'Confiar em Deus é mais do que buscar uma solução rápida. É reconhecer '
        'que nosso entendimento é limitado e abrir os caminhos cotidianos à '
        'direção do Senhor. Em Cristo, essa confiança não é passividade: é '
        'uma forma humilde e perseverante de viver.',
    application:
        'Antes de uma decisão de hoje, faça uma pausa, ore e considere qual '
        'atitude expressa amor, verdade e responsabilidade.',
    prayer:
        'Senhor, guia meus pensamentos e escolhas. Dá-me humildade para confiar '
        'em ti e sabedoria para agir com amor. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
  Devotional(
    id: 'daily-04',
    title: 'Graça para recomeçar',
    bibleReference: 'João 1:14–18',
    verseReference: 'João 1:14',
    bookId: 'joao',
    chapterNumber: 1,
    verseNumber: 14,
    reflection:
        'Em Jesus, a graça de Deus se aproxima de pessoas reais, com limites, '
        'perguntas e necessidade de recomeço. A verdade não precisa ser '
        'escondida, e a graça não precisa ser conquistada. Receber Cristo é '
        'aprender a viver com humildade diante de Deus e esperança para o '
        'próximo passo.',
    application:
        'Identifique uma área em que você precisa recomeçar e escolha hoje uma '
        'atitude pequena, honesta e possível.',
    prayer:
        'Pai, obrigado pela graça revelada em Jesus. Sustenta meu recomeço com '
        'verdade, esperança e amor. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
  Devotional(
    id: 'daily-05',
    title: 'Presença no vale',
    bibleReference: 'Salmos 1:1–6',
    verseReference: 'Salmos 1:3',
    bookId: 'salmos',
    chapterNumber: 1,
    verseNumber: 3,
    reflection:
        'O Salmo apresenta dois caminhos e convida a uma vida enraizada na '
        'Palavra. A fé não é uma promessa de facilidade, mas um caminho de '
        'constância diante de Deus. Hoje, você pode dar um passo simples e '
        'fiel nessa direção.',
    application:
        'Reserve alguns minutos para ler a Escritura com atenção e escolher uma '
        'verdade que deseja praticar hoje.',
    prayer:
        'Senhor, acompanha-me nos caminhos fáceis e difíceis. Que tua presença '
        'me ensine a viver com coragem e cuidado. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
  Devotional(
    id: 'daily-06',
    title: 'Um coração ensinável',
    bibleReference: 'Provérbios 3:1–8',
    verseReference: 'Provérbios 3:5',
    bookId: 'proverbios',
    chapterNumber: 3,
    verseNumber: 5,
    reflection:
        'A sabedoria bíblica alcança o interior e também as escolhas práticas. '
        'Cuidar do coração envolve prestar atenção ao que alimenta nossos '
        'pensamentos, palavras e atitudes. Deus nos chama a um caminho de '
        'discernimento que pode ser aprendido com constância e dependência.',
    application:
        'Observe uma influência que tem moldado seu dia e escolha uma fonte de '
        'verdade e vida para priorizar hoje.',
    prayer:
        'Deus, torna meu coração ensinável e guarda minhas palavras e escolhas. '
        'Conduze-me em teu caminho. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
  Devotional(
    id: 'daily-07',
    title: 'Um novo começo',
    bibleReference: 'João 3:1–21',
    verseReference: 'João 3:16',
    bookId: 'joao',
    chapterNumber: 15,
    verseNumber: 5,
    reflection:
        'Jesus conversa com Nicodemos sobre a necessidade de nascer de novo. A '
        'vida com Deus não começa pelo desempenho, mas pela graça que alcança '
        'pessoas reais e as chama à confiança. Esse convite continua aberto a '
        'quem está dando os primeiros passos na fé.',
    application:
        'Pense em uma área da vida que precisa de renovação e escolha uma ação '
        'pequena, honesta e possível para hoje.',
    prayer: 'Senhor Jesus, conduz meu coração a um novo começo pela tua graça. '
        'Ensina-me a viver com fé, verdade e esperança. Amém.',
    status: EditorialStatus.reviewRequired,
  ),
];
