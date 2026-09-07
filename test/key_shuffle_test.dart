import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/layouts.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

List<String?> _texts(KeyboardLayout layout) => [
      for (final row in layout)
        for (final key in row) key.text,
    ];

Future<void> _pump(
  WidgetTester tester, {
  KeyShuffle shuffle = KeyShuffle.none,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: KeyboardType.number,
          keyShuffle: shuffle,
          onKeyPressed: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('Digit Shuffle', () {
    test('keeps every digit exactly once', () {
      final out = shuffleDigitKeys(numberLayout, random: Random(7));
      final before = _texts(numberLayout).whereType<String>().toList()..sort();
      final after = _texts(out).whereType<String>().toList()..sort();
      expect(after, before);
    });

    test('leaves action keys and the decimal point where they were', () {
      final out = shuffleDigitKeys(numberLayout, random: Random(7));
      for (var r = 0; r < numberLayout.length; r++) {
        for (var c = 0; c < numberLayout[r].length; c++) {
          final original = numberLayout[r][c];
          final isDigit = original.keyType == KeyType.character &&
              original.text != null &&
              original.text!.length == 1 &&
              int.tryParse(original.text!) != null;
          if (!isDigit) {
            expect(
              out[r][c].text,
              original.text,
              reason: 'non-digit at $r,$c moved',
            );
            expect(out[r][c].action, original.action);
          }
        }
      }
    });

    test('actually permutes for at least one seed', () {
      // A shuffle that happened to be the identity would pass every other
      // check here, so prove some seed reorders the digits.
      final permuted = List.generate(
        20,
        (i) => _texts(shuffleDigitKeys(numberLayout, random: Random(i))),
      ).any((t) => t.toString() != _texts(numberLayout).toString());
      expect(permuted, isTrue);
    });

    test('never mutates the layout it was given', () {
      final before = _texts(numberLayout).toString();
      shuffleDigitKeys(numberLayout, random: Random(3));
      shuffleDigitKeys(numberLayout, random: Random(9));
      expect(_texts(numberLayout).toString(), before);
    });

    test('the same seed gives the same permutation', () {
      expect(
        _texts(shuffleDigitKeys(numberLayout, random: Random(42))),
        _texts(shuffleDigitKeys(numberLayout, random: Random(42))),
      );
    });

    test('a layout with fewer than two digits is returned unchanged', () {
      final one = <KeyRow>[
        [
          VirtualKey.character(text: '5'),
          VirtualKey.action(action: KeyAction.backSpace),
        ],
      ];
      expect(_texts(shuffleDigitKeys(one, random: Random(1))), ['5', null]);
      final none = <KeyRow>[
        [VirtualKey.action(action: KeyAction.backSpace)],
      ];
      expect(shuffleDigitKeys(none, random: Random(1)), none);
    });
  });

  group('Shuffle On The Keypad', () {
    testWidgets('off by default, digits sit in their usual places', (
      tester,
    ) async {
      await _pump(tester);
      await tester.pumpAndSettle();
      // Row order is 1..9 then . 0 backspace, so 1 is above 4.
      final one = tester.getCenter(find.text('1'));
      final four = tester.getCenter(find.text('4'));
      expect(one.dy, lessThan(four.dy));
      expect(one.dx, closeTo(four.dx, 0.01));
    });

    testWidgets('all ten digits are still present when shuffled', (
      tester,
    ) async {
      await _pump(tester, shuffle: KeyShuffle.onShow);
      await tester.pumpAndSettle();
      for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(find.text(d), findsOneWidget, reason: 'digit $d missing');
      }
    });

    testWidgets('positions hold still across rebuilds while typing', (
      tester,
    ) async {
      await _pump(tester, shuffle: KeyShuffle.onShow);
      await tester.pumpAndSettle();
      final before = tester.getCenter(find.text('7'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('7')), before);
    });

    testWidgets('a shuffled keypad still reports the key that was tapped', (
      tester,
    ) async {
      final pressed = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.number,
              keyShuffle: KeyShuffle.onShow,
              onKeyPressed: (key) => pressed.add(key.text),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(pressed, ['3']);
    });

    testWidgets('onEveryKey keeps all ten digits after several presses', (
      tester,
    ) async {
      await _pump(tester, shuffle: KeyShuffle.onEveryKey);
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
      }
      for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(find.text(d), findsOneWidget, reason: 'digit $d lost');
      }
    });
  });
}
