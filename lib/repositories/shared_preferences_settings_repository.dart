import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_settings.dart';
import 'local_settings_repository.dart';

class SharedPreferencesSettingsRepository implements LocalSettingsRepository {
  static const _displayNameKey = 'vida_com_cristo.display_name';
  static const _themePreferenceKey = 'vida_com_cristo.theme_preference';
  static const _editorialFontSizeKey = 'vida_com_cristo.editorial_font_size';

  @override
  Future<LocalSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalSettings(
      displayName: preferences.getString(_displayNameKey) ?? '',
      themePreference: _themePreferenceFromStorage(
        preferences.getString(_themePreferenceKey),
      ),
      editorialFontSize: _fontSizeFromStorage(
        preferences.getString(_editorialFontSizeKey),
      ),
    );
  }

  @override
  Future<void> save(LocalSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_displayNameKey, settings.displayName);
    await preferences.setString(
      _themePreferenceKey,
      settings.themePreference.name,
    );
    await preferences.setString(
      _editorialFontSizeKey,
      settings.editorialFontSize.name,
    );
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_displayNameKey);
    await preferences.remove(_themePreferenceKey);
    await preferences.remove(_editorialFontSizeKey);
  }

  AppThemePreference _themePreferenceFromStorage(String? value) {
    return AppThemePreference.values
            .where((item) => item.name == value)
            .firstOrNull ??
        AppThemePreference.system;
  }

  EditorialFontSize _fontSizeFromStorage(String? value) {
    return EditorialFontSize.values
            .where((item) => item.name == value)
            .firstOrNull ??
        EditorialFontSize.standard;
  }
}
