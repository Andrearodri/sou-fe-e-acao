import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/prayer_entry.dart';
import 'prayer_repository.dart';

abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class LocalPrayerRepository implements PrayerRepository {
  LocalPrayerRepository({SecureValueStore? store})
      : _store = store ?? FlutterSecureValueStore();

  static const _storageKey = 'vida_com_cristo.private_prayers';

  final SecureValueStore _store;

  @override
  Future<List<PrayerEntry>> loadAll() async {
    final raw = await _store.read(_storageKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Invalid prayer data');
    final entries = decoded
        .whereType<Map>()
        .map((item) => PrayerEntry.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  @override
  Future<void> save(PrayerEntry entry) async {
    final entries = await loadAll();
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      entries.add(entry);
    } else {
      entries[index] = entry;
    }
    await _write(entries);
  }

  @override
  Future<void> delete(String id) async {
    final entries = await loadAll()
      ..removeWhere((entry) => entry.id == id);
    await _write(entries);
  }

  @override
  Future<void> clear() => _store.delete(_storageKey);

  Future<void> _write(List<PrayerEntry> entries) {
    return _store.write(
      _storageKey,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }
}
