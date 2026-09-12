enum AppThemePreference { system, light, dark }

enum EditorialFontSize { small, standard, large }

extension EditorialFontSizeScale on EditorialFontSize {
  double get scale => switch (this) {
        EditorialFontSize.small => 0.9,
        EditorialFontSize.standard => 1,
        EditorialFontSize.large => 1.15,
      };
}

class LocalSettings {
  const LocalSettings({
    this.displayName = '',
    this.themePreference = AppThemePreference.system,
    this.editorialFontSize = EditorialFontSize.standard,
  });

  final String displayName;
  final AppThemePreference themePreference;
  final EditorialFontSize editorialFontSize;

  static const defaults = LocalSettings();

  LocalSettings copyWith({
    String? displayName,
    AppThemePreference? themePreference,
    EditorialFontSize? editorialFontSize,
  }) {
    return LocalSettings(
      displayName: displayName ?? this.displayName,
      themePreference: themePreference ?? this.themePreference,
      editorialFontSize: editorialFontSize ?? this.editorialFontSize,
    );
  }
}
