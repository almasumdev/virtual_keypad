import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Every character key on a layout, in order.
List<String> _letters(KeyboardLayout layout) => [
      for (final row in layout)
        for (final key in row)
          if (key.isCharacter) key.text!,
    ];

void main() {
  setUp(() {
    KeyboardLayoutProvider.instance.reset();
    initializeKeyboardLayouts();
  });

  group('Built-In Languages', () {
    test('every language registers under its own code', () {
      const codes = [
        'ar', 'bn', 'de', 'en', 'es', 'fr', 'he', 'hi', //
        'it', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'uk',
      ];
      final provider = KeyboardLayoutProvider.instance;
      for (final code in codes) {
        final language = provider.getLanguage(code);
        expect(language, isNotNull, reason: '$code is not registered');
        expect(language!.code, code);
      }
    });
  });

  group('Italian', () {
    KeyboardLanguage italian() =>
        KeyboardLayoutProvider.instance.getLanguage('it')!;

    test('it is named in English and in Italian', () {
      expect(italian().name, 'Italian');
      expect(italian().nativeName, 'Italiano');
    });

    test('the letter page is plain QWERTY with no Spanish ñ', () {
      final letters = _letters(italian().textLayouts.primary);
      expect(letters.take(10).join(), 'qwertyuiop');
      expect(letters, isNot(contains('ñ')));
    });

    test('the grave and acute vowels Italian uses are reachable', () {
      final accents = _letters(italian().textLayouts.tertiary!);
      for (final v in ['à', 'è', 'é', 'ì', 'ò', 'ù']) {
        expect(accents, contains(v), reason: '$v is missing');
      }
    });

    test('no Spanish-only punctuation is left behind', () {
      final symbols = _letters(italian().textLayouts.secondary!);
      expect(symbols, isNot(contains('¿')));
      expect(symbols, isNot(contains('¡')));
    });
  });

  group('Ukrainian', () {
    KeyboardLanguage ukrainian() =>
        KeyboardLayoutProvider.instance.getLanguage('uk')!;

    test('it is named in English and in Ukrainian', () {
      expect(ukrainian().name, 'Ukrainian');
      expect(ukrainian().nativeName, 'Українська');
    });

    test('the letter rows follow the standard Ukrainian layout', () {
      final rows = [
        for (final row in ukrainian().textLayouts.primary)
          [
            for (final key in row)
              if (key.isCharacter) key.text!,
          ].join(),
      ];
      expect(rows[0], 'йцукенгшщзхї');
      expect(rows[1], 'фівапролджє');
      expect(rows[2], 'ячсмитьбю');
    });

    test('the letters that exist only in Russian are absent', () {
      final all = [
        ..._letters(ukrainian().textLayouts.primary),
        ..._letters(ukrainian().textLayouts.secondary!),
        ..._letters(ukrainian().textLayouts.tertiary!),
      ];
      for (final letter in ['ы', 'э', 'ё', 'ъ']) {
        expect(all, isNot(contains(letter)), reason: '$letter is Russian');
      }
    });

    test('ґ and the apostrophe are reachable', () {
      final extra = _letters(ukrainian().textLayouts.tertiary!);
      expect(extra, contains('ґ'));
      expect(extra, contains("'"));
    });

    test('email and URL pages stay Latin', () {
      final email = _letters(ukrainian().emailLayouts!.primary);
      expect(email, contains('@'));
      expect(email.take(10).join(), 'qwertyuiop');
    });
  });

  group('Hebrew', () {
    KeyboardLanguage hebrew() =>
        KeyboardLayoutProvider.instance.getLanguage('he')!;

    test('it is named in English and in Hebrew, and reads right to left', () {
      expect(hebrew().name, 'Hebrew');
      expect(hebrew().nativeName, 'עברית');
      expect(hebrew().isRTL, isTrue);
    });

    test('the letter rows follow the standard Hebrew layout', () {
      final rows = [
        for (final row in hebrew().textLayouts.primary)
          [
            for (final key in row)
              if (key.isCharacter) key.text!,
          ].join(),
      ];
      expect(rows[0], 'קראטוןםפ');
      expect(rows[1], 'שדגכעיחלךף');
      expect(rows[2], 'זסבהנמצתץ');
    });

    test('the final forms Hebrew needs are all present', () {
      final letters = _letters(hebrew().textLayouts.primary);
      for (final f in ['ן', 'ם', 'ך', 'ף', 'ץ']) {
        expect(letters, contains(f), reason: 'final form $f is missing');
      }
    });

    test('no Latin accents are left over from the layout it was built on', () {
      final all = [
        ..._letters(hebrew().textLayouts.primary),
        ..._letters(hebrew().textLayouts.tertiary!),
      ];
      for (final c in ['á', 'é', 'ñ', '¿']) {
        expect(all, isNot(contains(c)));
      }
    });

    test('email and URL pages stay Latin', () {
      expect(_letters(hebrew().emailLayouts!.primary).take(10).join(),
          'qwertyuiop');
      expect(
          _letters(hebrew().urlLayouts!.primary).take(10).join(), 'qwertyuiop');
    });
  });

  group('Polish', () {
    KeyboardLanguage polish() =>
        KeyboardLayoutProvider.instance.getLanguage('pl')!;

    test('it is named in English and in Polish', () {
      expect(polish().name, 'Polish');
      expect(polish().nativeName, 'Polski');
      expect(polish().isRTL, isFalse);
    });

    test('the letter page is plain QWERTY', () {
      final letters = _letters(polish().textLayouts.primary);
      expect(letters.take(10).join(), 'qwertyuiop');
      expect(letters, isNot(contains('ñ')));
    });

    test('all nine Polish letters are reachable', () {
      final accents = _letters(polish().textLayouts.tertiary!);
      for (final c in ['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż']) {
        expect(accents, contains(c), reason: '$c is missing');
      }
    });

    test('the currency key is the zloty, not the euro', () {
      final symbols = _letters(polish().textLayouts.secondary!);
      expect(symbols, contains('zł'));
      expect(symbols, isNot(contains('€')));
    });
  });

  group('Switching To A New Language', () {
    testWidgets('the Ukrainian keyboard renders its letters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.text,
              initialLanguage: 'uk',
              availableLanguages: ['uk'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ї'), findsOneWidget);
      expect(find.text('є'), findsOneWidget);
    });

    testWidgets('the Hebrew keyboard renders right to left', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.text,
              initialLanguage: 'he',
              availableLanguages: ['he'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('א'), findsOneWidget);
      expect(find.text('ץ'), findsOneWidget);
    });

    testWidgets('the Italian keyboard renders its letters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.text,
              initialLanguage: 'it',
              availableLanguages: ['it'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('q'), findsOneWidget);
      expect(find.text('ñ'), findsNothing);
    });
  });
}
