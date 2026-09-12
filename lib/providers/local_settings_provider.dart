import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/local_settings.dart';
import '../repositories/local_settings_repository.dart';
import '../repositories/shared_preferences_settings_repository.dart';

class LocalSettingsProvider extends ChangeNotifier {
  LocalSettingsProvider({
    LocalSettingsRepository? repository,
    bool loadOnCreate = true,
  }) : _repository = repository ?? SharedPreferencesSettingsRepository() {
    if (loadOnCreate) unawaited(load());
  }

  final LocalSettingsRepository _repository;
  LocalSettings _settings = LocalSettings.defaults;
  bool _hasLocalMutations = false;
  bool _disposed = false;

  String get displayName => _settings.displayName;
  AppThemePreference get themePreference => _settings.themePreference;
  EditorialFontSize get editorialFontSize => _settings.editorialFontSize;
  double get editorialFontScale => _settings.editorialFontSize.scale;

  Future<void> load() async {
    try {
      final settings = await _repository.load();
      if (!_hasLocalMutations) _settings = settings;
    } catch (_) {
      if (!_hasLocalMutations) _settings = LocalSettings.defaults;
    }
    _notify();
  }

  Future<void> setDisplayName(String value) {
    return _update(_settings.copyWith(displayName: value.trim()));
  }

  Future<void> setThemePreference(AppThemePreference value) {
    return _update(_settings.copyWith(themePreference: value));
  }

  Future<void> setEditorialFontSize(EditorialFontSize value) {
    return _update(_settings.copyWith(editorialFontSize: value));
  }

  Future<void> clear() async {
    _hasLocalMutations = true;
    _settings = LocalSettings.defaults;
    _notify();
    try {
      await _repository.clear();
    } catch (_) {
      // Defaults remain usable if local storage is unavailable.
    }
  }

  Future<void> _update(LocalSettings value) async {
    _hasLocalMutations = true;
    _settings = value;
    _notify();
    try {
      await _repository.save(value);
    } catch (_) {
      // Keep the current guest session usable when persistence fails.
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
