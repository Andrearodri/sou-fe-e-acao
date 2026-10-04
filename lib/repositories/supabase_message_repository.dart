import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/biblical_message.dart';
import 'local_message_repository.dart';
import 'message_repository.dart';

/// Reads published server messages, retaining the licensed pilot for offline
/// use and for deployments where the optional migration has not been applied.
class SupabaseMessageRepository implements MessageRepository {
  SupabaseMessageRepository(
    this.client, {
    this.fallback = const LocalMessageRepository(),
  });

  final SupabaseClient client;
  final MessageRepository fallback;
  bool _usingFallback = false;

  @override
  Future<MessagePage> load({
    String query = '',
    String? category,
    Set<String>? favoriteSlugs,
    int offset = 0,
    int limit = 8,
  }) async {
    if (favoriteSlugs != null && favoriteSlugs.isEmpty) {
      return const MessagePage([], hasMore: false);
    }
    if (_usingFallback) {
      final local = await fallback.load(
          query: query,
          category: category,
          favoriteSlugs: favoriteSlugs,
          offset: offset,
          limit: limit);
      return MessagePage(local.items, hasMore: local.hasMore, offline: true);
    }
    try {
      var request = client
          .from('messages')
          .select<List<Map<String, dynamic>>>(
            'slug,text,reference,translation,category,background_url,featured,display_order',
          )
          .eq('published', true);
      if (category != null) request = request.eq('category', category);
      if (favoriteSlugs != null) {
        request = request.in_('id', favoriteSlugs.toList());
      }
      final term = query.trim().replaceAll(RegExp(r'[%_\\]'), '');
      if (term.isNotEmpty) request = request.ilike('search_text', '%$term%');
      final rows = await request
          .order('display_order', ascending: true)
          .range(offset, offset + limit);
      if (rows.isEmpty && offset == 0 && query.isEmpty && category == null) {
        _usingFallback = true;
        final local = await fallback.load(limit: limit);
        return MessagePage(local.items, hasMore: local.hasMore, offline: true);
      }
      return MessagePage(
        rows.take(limit).map(BiblicalMessage.fromJson).toList(),
        hasMore: rows.length > limit,
      );
    } catch (_) {
      _usingFallback = true;
      final local = await fallback.load(
        query: query,
        category: category,
        favoriteSlugs: favoriteSlugs,
        offset: offset,
        limit: limit,
      );
      return MessagePage(local.items, hasMore: local.hasMore, offline: true);
    }
  }

  @override
  Future<BiblicalMessage?> bySlug(String slug) async {
    if (_usingFallback) return fallback.bySlug(slug);
    try {
      final row = await client
          .from('messages')
          .select<Map<String, dynamic>?>(
            'slug,text,reference,translation,category,background_url,featured,display_order',
          )
          .eq('published', true)
          .eq('slug', slug)
          .maybeSingle();
      if (row != null) return BiblicalMessage.fromJson(row);
    } catch (_) {
      // The local pilot still supports its own deep links while offline.
    }
    return fallback.bySlug(slug);
  }
}
