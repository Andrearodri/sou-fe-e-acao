import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'models/local_settings.dart';
import 'providers/auth_provider.dart';
import 'providers/local_settings_provider.dart';
import 'providers/today_provider.dart';
import 'repositories/local_progress_repository.dart';
import 'repositories/local_settings_repository.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const config = SupabaseConfig();
  SupabaseClient? authClient;
  if (config.validationError == null) {
    try {
      await Supabase.initialize(url: config.url, anonKey: config.anonKey);
      authClient = Supabase.instance.client;
    } catch (_) {
      authClient = null;
    }
  }
  runApp(MyApp(authClient: authClient));
}

class MyApp extends StatefulWidget {
  const MyApp({
    this.authClient,
    this.settingsRepository,
    this.progressRepository,
    super.key,
  });

  final SupabaseClient? authClient;
  final LocalSettingsRepository? settingsRepository;
  final LocalProgressRepository? progressRepository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LocalSettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = LocalSettingsProvider(
      repository: widget.settingsRepository,
    );
  }

  @override
  void dispose() {
    _settingsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(client: widget.authClient)),
        ChangeNotifierProvider.value(value: _settingsProvider),
      ],
      child: Consumer<LocalSettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Vida com Cristo',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: _themeModeFor(settings.themePreference),
          home: AuthWrapper(
            guestFirst: true,
            progressRepository: widget.progressRepository,
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: Color(dark ? 0xFF7BA370 : 0xFF4A6741),
      brightness: brightness,
    ).copyWith(
      primary: Color(dark ? 0xFF7BA370 : 0xFF4A6741),
      primaryContainer: Color(dark ? 0xFF1E2A1C : 0xFFE8F0E6),
      surface: Color(dark ? 0xFF1A1A24 : 0xFFFFFFFF),
      onSurface: Color(dark ? 0xFFF0F0F5 : 0xFF1A1A2E),
      onSurfaceVariant: Color(dark ? 0xFF9CA3AF : 0xFF6B7280),
      secondary: Color(dark ? 0xFFD4A574 : 0xFFC4956A),
      tertiary: Color(dark ? 0xFFD4A574 : 0xFFC4956A),
    );
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Color(dark ? 0xFF0F0F14 : 0xFFFAFAF8),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Color(dark ? 0xFFF0F0F5 : 0xFF1A1A2E),
        displayColor: Color(dark ? 0xFFF0F0F5 : 0xFF1A1A2E),
      ),
      cardTheme: CardThemeData(
        color: Color(dark ? 0xFF1A1A24 : 0xFFFFFFFF),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Color(dark ? 0xFF1A1A24 : 0xFFFFFFFF),
        indicatorColor: Color(dark ? 0xFF1E2A1C : 0xFFE8F0E6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(dark ? 0xFF1A1A24 : 0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  ThemeMode _themeModeFor(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({
    this.guestFirst = true,
    this.progressRepository,
    super.key,
  });

  final bool guestFirst;
  final LocalProgressRepository? progressRepository;

  @override
  Widget build(BuildContext context) {
    if (!guestFirst) {
      final content = context.watch<AuthProvider>().isAuthenticated
          ? const HomeScreen()
          : const AuthScreen();
      return content is HomeScreen
          ? ChangeNotifierProvider(
              create: (_) => TodayProvider(repository: progressRepository),
              child: content,
            )
          : content;
    }
    return AppShell(progressRepository: progressRepository);
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vida com Cristo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_outlined, size: 48),
                  const SizedBox(height: 16),
                  const Text('Configuração necessária',
                      style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
