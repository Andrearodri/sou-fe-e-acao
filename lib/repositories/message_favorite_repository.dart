import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageFavoriteRepository {
  const MessageFavoriteRepository(this.client);

  final SupabaseClient? client;
  static const _guestKey = 'sou_feeacao.message_favorites.v1';

  Future<Set<String>> load(String? userId) async {
    if (userId != null && client != null) {
      final rows = await client!
          .from('message_favorites')
          .select<List<Map<String, dynamic>>>('message_id')
          .eq('user_id', userId);
      return rows.map((row) => row['message_id'] as String).toSet();
    }
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_guestKey) ?? []).toSet();
  }

  Future<bool> toggle(
    String slug, {
    required String? userId,
    required bool currentlyFavorite,
  }) async {
    if (userId != null && client != null) {
      if (currentlyFavorite) {
        await client!
            .from('message_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('message_id', slug);
      } else {
        await client!.from('message_favorites').insert({
          'user_id': userId,
          'message_id': slug,
        });
      }
      return !currentlyFavorite;
    }
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_guestKey) ?? []).toSet();
    if (currentlyFavorite) {
      favorites.remove(slug);
    } else {
      favorites.add(slug);
    }
    await prefs.setStringList(_guestKey, favorites.toList()..sort());
    return !currentlyFavorite;
  }
}
