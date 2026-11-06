import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/screens/qr_generator_screen.dart';
import 'presentation/theme/app_theme.dart';

const _darkModePreferenceKey = 'isDarkMode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final savedDarkMode = preferences.getBool(_darkModePreferenceKey);
  runApp(
    QRGenioApp(
      preferences: preferences,
      initialThemeMode: savedDarkMode == null
          ? ThemeMode.system
          : savedDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
    ),
  );
}

class QRGenioApp extends StatefulWidget {
  final SharedPreferences preferences;
  final ThemeMode initialThemeMode;

  const QRGenioApp({
    super.key,
    required this.preferences,
    required this.initialThemeMode,
  });

  @override
  State<QRGenioApp> createState() => _QRGenioAppState();
}

class _QRGenioAppState extends State<QRGenioApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _toggleTheme() async {
    final nextThemeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    final saved = await widget.preferences.setBool(
      _darkModePreferenceKey,
      nextThemeMode == ThemeMode.dark,
    );
    if (!saved) {
      throw Exception('Theme preference could not be saved.');
    }

    if (!mounted) return;
    setState(() {
      _themeMode = nextThemeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Genio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Builder(
        builder: (context) => QRGeneratorScreen(
          onThemeToggle: _toggleTheme,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}
