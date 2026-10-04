import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vida_com_cristo/content/local_messages.dart';
import 'package:vida_com_cristo/main.dart';
import 'package:vida_com_cristo/models/local_settings.dart';
import 'package:vida_com_cristo/repositories/local_message_repository.dart';
import 'package:vida_com_cristo/repositories/local_settings_repository.dart';
import 'package:vida_com_cristo/repositories/memory_progress_repository.dart';
import 'package:vida_com_cristo/repositories/message_favorite_repository.dart';
import 'package:vida_com_cristo/screens/message_image_composer.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('message links and WhatsApp encoding retain accents and reference', () {
    final message = localMessages.first;
    expect(message.uri.toString(),
        'https://soufeeacao.com.br/mensagens/confiar-de-todo-coracao');
    expect(message.copyText, contains('Provérbios 3:5\n\nhttps://'));
    expect(message.whatsappUri.host, 'wa.me');
    expect(message.whatsappUri.queryParameters['text'], message.shareText);
  });

  test('local catalogue filters, searches and paginates', () async {
    const repository = LocalMessageRepository();
    final first = await repository.load(limit: 5);
    expect(first.items, hasLength(5));
    expect(first.hasMore, isTrue);
    final second = await repository.load(offset: 5, limit: 8);
    expect(second.items, hasLength(7));
    expect(second.hasMore, isFalse);
    expect((await repository.load(query: 'Provérbios 3:5')).items.single.slug,
        'confiar-de-todo-coracao');
    expect((await repository.load(category: 'Oração')).items.single.slug,
        'clamo-e-ele-responde');
    expect(
        (await repository.load(favoriteSlugs: {'clamo-e-ele-responde'}))
            .items
            .single
            .slug,
        'clamo-e-ele-responde');
    expect((await repository.load(favoriteSlugs: {})).items, isEmpty);
    expect((await repository.bySlug('desconhecida')), isNull);
  });

  test('guest favorites persist and can be removed without duplicates',
      () async {
    const favorites = MessageFavoriteRepository(null);
    expect(await favorites.load(null), isEmpty);
    expect(
        await favorites.toggle('confiar-de-todo-coracao',
            userId: null, currentlyFavorite: false),
        isTrue);
    expect(await favorites.load(null), {'confiar-de-todo-coracao'});
    expect(
        await favorites.toggle('confiar-de-todo-coracao',
            userId: null, currentlyFavorite: true),
        isFalse);
    expect(await favorites.load(null), isEmpty);
  });

  testWidgets('visitor opens messages, copies and previews art at phone width',
      (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mais').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mensagens'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Provérbios 3:5'), findsWidgets);
    await tester.ensureVisible(find.text('Copiar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Copiar').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Mensagem copiada'), findsOneWidget);
    await tester.ensureVisible(find.text('Criar imagem').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar imagem').first);
    await tester.pumpAndSettle();
    expect(find.byType(MessageImageComposer), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -550));
    await tester.pumpAndSettle();
    expect(find.text('Baixar PNG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct message URL opens the correct verse at desktop width',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester
        .pumpWidget(_app(initialRoute: '/mensagens/confiar-de-todo-coracao'));
    await tester.pumpAndSettle();
    expect(find.text('Mensagem bíblica'), findsOneWidget);
    expect(find.textContaining('Confia no SENHOR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('messages fit common phone, tablet and desktop widths',
      (tester) async {
    for (final width in [320.0, 375.0, 768.0, 1024.0, 1440.0]) {
      await tester.binding.setSurfaceSize(Size(width, 900));
      await tester.pumpWidget(_app(initialRoute: '/mensagens'));
      await tester.pumpAndSettle();
      expect(find.text('Palavras para guardar e compartilhar'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Overflow at $width px');
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('every pilot verse fits inside the square art on a narrow phone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final message in localMessages) {
      await tester.pumpWidget(MaterialApp(
        home:
            MessageImageComposer(key: ValueKey(message.slug), message: message),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Esta mensagem é longa demais para caber na arte.'),
          findsNothing,
          reason: message.reference);
      expect(tester.takeException(), isNull, reason: message.reference);
    }
  });

  testWidgets('list remains usable with enlarged system text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 850));
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await tester.pumpWidget(_app(initialRoute: '/mensagens'));
    await tester.pumpAndSettle();
    expect(find.text('Palavras para guardar e compartilhar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({String? initialRoute}) => MyApp(
      initialRoute: initialRoute,
      settingsRepository: _MemorySettingsRepository(),
      progressRepository: MemoryProgressRepository(),
    );

class _MemorySettingsRepository implements LocalSettingsRepository {
  LocalSettings settings = LocalSettings.defaults;
  @override
  Future<void> clear() async => settings = LocalSettings.defaults;
  @override
  Future<LocalSettings> load() async => settings;
  @override
  Future<void> save(LocalSettings value) async => settings = value;
}
