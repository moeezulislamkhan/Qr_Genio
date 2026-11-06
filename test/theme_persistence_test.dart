import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_genio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('saves the selected theme mode across app instances', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      QRGenioApp(
        preferences: preferences,
        initialThemeMode: ThemeMode.system,
      ),
    );
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(preferences.getBool('isDarkMode'), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      QRGenioApp(
        preferences: preferences,
        initialThemeMode: preferences.getBool('isDarkMode')!
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
    );
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
