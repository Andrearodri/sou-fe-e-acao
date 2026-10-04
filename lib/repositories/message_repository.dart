import '../models/biblical_message.dart';

class MessagePage {
  const MessagePage(this.items, {required this.hasMore, this.offline = false});
  final List<BiblicalMessage> items;
  final bool hasMore;
  final bool offline;
}

abstract class MessageRepository {
  Future<MessagePage> load({
    String query = '',
    String? category,
    Set<String>? favoriteSlugs,
    int offset = 0,
    int limit = 8,
  });
  Future<BiblicalMessage?> bySlug(String slug);
}
