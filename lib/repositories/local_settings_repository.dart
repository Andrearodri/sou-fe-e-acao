import '../models/local_settings.dart';

abstract interface class LocalSettingsRepository {
  Future<LocalSettings> load();
  Future<void> save(LocalSettings settings);
  Future<void> clear();
}
