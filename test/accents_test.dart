import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Builds a keyboard and records every character it reports.
Future<List<String>> _pump(
  WidgetTester tester, {
  Map<String, List<String>>? accents,
  String language = 'en',
}) async {
  final typed = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: KeyboardType.text,
          accents: accents,
          initialLanguage: language,
          availableLanguages: [language],
          onKeyPressedWithText: (_, text) {
            if (text != null) typed.add(text);
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return typed;
}

/// Holds the key showing [label] until its popup opens.
Future<void> _hold(WidgetTester tester, String label) async {
  await tester.longPress(find.text(label).first);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    KeyboardLayoutProvider.instance.reset();
    initializeKeyboardLayouts();
  });

  group('Accent Popup', () {
    testWidgets('holding a letter offers its accents', (tester) async {
      await _pump(tester);
      await _hold(tester, 'a');
      for (final accent in ['à', 'á', 'â', 'ä']) {
        expect(find.text(accent), findsOneWidget, reason: '$accent missing');
      }
    });

    testWidgets('choosing one inserts it', (tester) async {
      final typed = await _pump(tester);
      await _hold(tester, 'a');
      await tester.tap(find.text('á'));
      await tester.pumpAndSettle();
      expect(typed, ['á']);
    });

    testWidgets('a letter with no accents opens nothing', (tester) async {
      await _pump(tester);
      await _hold(tester, 'q');
      // The popup would add a second copy of the held letter.
      expect(find.text('q'), findsOneWidget);
    });

    testWidgets('an empty map turns the popup off', (tester) async {
      await _pump(tester, accents: const {});
      await _hold(tester, 'a');
      expect(find.text('à'), findsNothing);
    });

    testWidgets('a supplied map replaces the built-in one', (tester) async {
      await _pump(tester, accents: const {
        'a': ['ā'],
      });
      await _hold(tester, 'a');
      expect(find.text('ā'), findsOneWidget);
      expect(find.text('à'), findsNothing);
    });

    testWidgets('the accents follow shift into uppercase', (tester) async {
      final typed = await _pump(tester);
      // Shift first, so the letters are uppercase.
      await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
      await tester.pumpAndSettle();
      await _hold(tester, 'A');
      expect(find.text('À'), findsOneWidget);
      await tester.tap(find.text('À'));
      await tester.pumpAndSettle();
      expect(typed, ['À']);
    });

    testWidgets('dismissing it inserts nothing', (tester) async {
      final typed = await _pump(tester);
      await _hold(tester, 'a');
      // Tap away from the menu to close it.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(typed, isEmpty);
    });

    testWidgets('a plain tap still types the base letter', (tester) async {
      final typed = await _pump(tester);
      await tester.tap(find.text('a'));
      await tester.pumpAndSettle();
      expect(typed, ['a']);
    });

    testWidgets('holding space still opens the language picker', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.text,
              availableLanguages: ['en', 'fr'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.longPress(find.text('space'));
      await tester.pumpAndSettle();
      expect(find.text('Français'), findsOneWidget);
    });
  });

  group('Accent Table', () {
    test('it covers the letters the built-in languages need', () {
      // Each of these is carried by at least one shipped layout.
      for (final entry in {
        'a': 'ą',
        'c': 'ć',
        'e': 'ę',
        'l': 'ł',
        'n': 'ń',
        'o': 'ó',
        's': 'ś',
        'z': 'ż',
        'u': 'ü',
        'i': 'ı',
        'g': 'ğ',
      }.entries) {
        expect(
          kLatinAccents[entry.key],
          contains(entry.value),
          reason: '${entry.value} is not offered on ${entry.key}',
        );
      }
    });

    test('every key is a single lowercase letter', () {
      for (final key in kLatinAccents.keys) {
        expect(key.length, 1, reason: '$key is not one character');
        expect(key, key.toLowerCase(), reason: '$key is not lowercase');
      }
    });

    test('no entry repeats itself or its base letter', () {
      kLatinAccents.forEach((base, options) {
        expect(options.toSet(), hasLength(options.length), reason: base);
        expect(options, isNot(contains(base)), reason: base);
      });
    });
  });
}
