import '../content/local_messages.dart';
import '../models/biblical_message.dart';
import 'message_repository.dart';

class LocalMessageRepository implements MessageRepository {
  const LocalMessageRepository();

  @override
  Future<MessagePage> load({
    String query = '',
    String? category,
    Set<String>? favoriteSlugs,
    int offset = 0,
    int limit = 8,
  }) async {
    final term = query.trim().toLowerCase();
    final filtered = localMessages.where((message) {
      return (category == null || message.category == category) &&
          (favoriteSlugs == null || favoriteSlugs.contains(message.slug)) &&
          (term.isEmpty ||
              '${message.text} ${message.reference}'.toLowerCase().contains(
                    term,
                  ));
    }).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    if (offset >= filtered.length) return const MessagePage([], hasMore: false);
    final end = (offset + limit).clamp(0, filtered.length);
    return MessagePage(
      filtered.sublist(offset, end),
      hasMore: end < filtered.length,
    );
  }

  @override
  Future<BiblicalMessage?> bySlug(String slug) async {
    for (final message in localMessages) {
      if (message.slug == slug) return message;
    }
    return null;
  }
}
