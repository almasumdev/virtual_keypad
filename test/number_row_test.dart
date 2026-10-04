import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Builds a keypad and records every character it reports.
Future<List<String>> _pump(
  WidgetTester tester, {
  bool showNumberRow = true,
  KeyboardType type = KeyboardType.text,
  KeyboardLayout? customLayout,
}) async {
  final typed = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: type,
          showNumberRow: showNumberRow,
          customLayout: customLayout,
          height: 400,
          availableLanguages: const ['en'],
          initialLanguage: 'en',
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

/// Every digit `1` through `0`, in the order the row shows them.
const _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

void main() {
  setUp(() {
    KeyboardLayoutProvider.instance.reset();
    initializeKeyboardLayouts();
  });

  group('Number Row', () {
    testWidgets('it shows every digit above the letters', (tester) async {
      await _pump(tester);
      for (final digit in _digits) {
        expect(find.text(digit), findsOneWidget, reason: '$digit missing');
      }
      // The letters are still there underneath.
      expect(find.text('q'), findsOneWidget);
      expect(find.text('p'), findsOneWidget);
    });

    testWidgets('it is off by default', (tester) async {
      await _pump(tester, showNumberRow: false);
      expect(find.text('1'), findsNothing);
      expect(find.text('q'), findsOneWidget);
    });

    testWidgets('tapping a digit types it', (tester) async {
      final typed = await _pump(tester);
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      expect(typed, ['7']);
    });

    testWidgets('the row sits above the first letter row', (tester) async {
      await _pump(tester);
      final one = tester.getCenter(find.text('1'));
      final q = tester.getCenter(find.text('q'));
      expect(one.dy, lessThan(q.dy), reason: 'the digits are not on top');
    });

    testWidgets('shift leaves the digits alone', (tester) async {
      final typed = await _pump(tester);
      await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Q'), findsOneWidget, reason: 'shift did not apply');
      // A digit has no uppercase form, so it must read the same and type the
      // same with shift on.
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(typed, ['1']);
    });

    testWidgets('the symbols page does not gain a second digit row', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('1'), findsOneWidget);
      // Switch to the symbols page, which carries digits of its own.
      await tester.tap(find.text('123'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget, reason: 'the digits doubled up');
    });

    testWidgets('a numeric keypad is left as it is', (tester) async {
      await _pump(tester, type: KeyboardType.number);
      // All ten digits, each exactly once: no row was prepended.
      for (final digit in _digits) {
        expect(find.text(digit), findsOneWidget, reason: '$digit duplicated');
      }
    });

    testWidgets('a phone keypad is left as it is', (tester) async {
      await _pump(tester, type: KeyboardType.phone);
      for (final digit in _digits) {
        expect(find.text(digit), findsOneWidget, reason: '$digit duplicated');
      }
    });

    testWidgets('an email keyboard gets the row', (tester) async {
      await _pump(tester, type: KeyboardType.emailAddress);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('@'), findsOneWidget);
    });

    testWidgets('a custom layout is untouched', (tester) async {
      await _pump(
        tester,
        type: KeyboardType.custom,
        customLayout: [
          [VirtualKey.character(text: 'a'), VirtualKey.character(text: 'b')],
        ],
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('a layout that already opens with digits gains no row', (
      tester,
    ) async {
      // The guard is keyed on a first row of exactly the ten digits, so a
      // rebuild cannot keep stacking rows.
      await _pump(tester);
      await tester.pump();
      for (final digit in _digits) {
        expect(find.text(digit), findsOneWidget, reason: '$digit duplicated');
      }
    });
  });
}
