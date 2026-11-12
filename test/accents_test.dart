// ignore: deprecated_member_use
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

    testWidgets('with shift on, ß is offered as the capital ẞ', (
      tester,
    ) async {
      // toUpperCase leaves ß as it is, so the uppercase menu used to offer a
      // lowercase letter.
      final typed = await _pump(tester);
      await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
      await tester.pumpAndSettle();
      await _hold(tester, 'S');
      expect(find.text('ẞ'), findsOneWidget);
      expect(find.text('ß'), findsNothing);
      await tester.tap(find.text('ẞ'));
      await tester.pumpAndSettle();
      expect(typed, ['ẞ']);
    });

    testWidgets('with shift on, the I key offers Turkish dotted İ', (
      tester,
    ) async {
      // Dotless ı uppercases to I, the key itself, which was useless; the
      // capital a Turkish writer needs there is İ.
      await _pump(tester);
      await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
      await tester.pumpAndSettle();
      await _hold(tester, 'I');
      expect(find.text('İ'), findsOneWidget);
      // Only the key itself shows I; the menu does not repeat it.
      expect(find.text('I'), findsOneWidget);
    });

    testWidgets('lowercase alternates are unchanged', (tester) async {
      await _pump(tester);
      await _hold(tester, 's');
      expect(find.text('ß'), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      await _hold(tester, 'i');
      expect(find.text('ı'), findsOneWidget);
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

    test('it covers the Hungarian, Romanian, Baltic and Icelandic letters', () {
      for (final entry in {
        'a': 'āă',
        'd': 'ð',
        'e': 'ēė',
        'g': 'ģ',
        'i': 'īį',
        'k': 'ķ',
        'l': 'ļ',
        'n': 'ņ',
        'o': 'ő',
        's': 'ș',
        't': 'țþ',
        'u': 'űūų',
      }.entries) {
        for (final letter in entry.value.split('')) {
          expect(
            kLatinAccents[entry.key],
            contains(letter),
            reason: '$letter is not offered on ${entry.key}',
          );
        }
      }
    });
  });

  group('Accent Casing', () {
    Future<void> shiftOn(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
      await tester.pumpAndSettle();
    }

    test('every letter has a capital the uppercase menu can offer', () {
      // ß and ı are the two a plain toUpperCase gets wrong, and the keyboard
      // maps those itself. Anything else that failed here would show a lowercase
      // letter in an uppercase menu.
      const handledByTheKeyboard = {'ß', 'ı'};
      kLatinAccents.forEach((base, options) {
        for (final option in options) {
          if (handledByTheKeyboard.contains(option)) continue;
          final upper = option.toUpperCase();
          expect(upper.length, 1, reason: '$option has no single capital');
          expect(upper, isNot(option), reason: '$option has no capital');
          expect(upper, isNot(base.toUpperCase()), reason: option);
        }
      });
    });

    testWidgets('a capital from the new letters is what gets typed', (
      tester,
    ) async {
      for (final entry in {'O': 'Ő', 'S': 'Ș', 'T': 'Þ', 'K': 'Ķ'}.entries) {
        final typed = await _pump(tester);
        await shiftOn(tester);
        await _hold(tester, entry.key);
        await tester.tap(find.text(entry.value));
        await tester.pumpAndSettle();
        expect(typed, [entry.value]);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('the longest row can still be reached and chosen', (
      tester,
    ) async {
      // Ten options on one key, on a short screen: the menu has to scroll.
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final typed = await _pump(tester);
      await _hold(tester, 'a');
      final last = find.text(kLatinAccents['a']!.last);
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(typed, [kLatinAccents['a']!.last]);
    });
  });
}
