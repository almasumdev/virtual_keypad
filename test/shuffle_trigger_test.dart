import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// The on-screen position of every digit, as a comparable signature.
String _digitLayout(WidgetTester tester) {
  final entries = <String>[];
  for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
    final finder = find.text(d);
    if (finder.evaluate().isEmpty) continue;
    final c = tester.getCenter(finder);
    entries.add('$d@${c.dx.round()},${c.dy.round()}');
  }
  return entries.join('|');
}

Future<void> _pump(
  WidgetTester tester,
  Listenable trigger, {
  KeyShuffle shuffle = KeyShuffle.onShow,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: KeyboardType.number,
          keyShuffle: shuffle,
          shuffleTrigger: trigger,
          onKeyPressed: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('Shuffle Trigger', () {
    testWidgets('firing it rearranges the digits', (tester) async {
      final trigger = ChangeNotifier();
      addTearDown(trigger.dispose);
      await _pump(tester, trigger);
      await tester.pumpAndSettle();

      final before = _digitLayout(tester);
      // One shuffle can land on the same arrangement by chance, so fire a few
      // times and require that at least one of them differs.
      var changed = false;
      for (var i = 0; i < 12 && !changed; i++) {
        trigger.notifyListeners();
        await tester.pumpAndSettle();
        changed = _digitLayout(tester) != before;
      }
      expect(changed, isTrue);
    });

    testWidgets('all ten digits survive a fire', (tester) async {
      final trigger = ChangeNotifier();
      addTearDown(trigger.dispose);
      await _pump(tester, trigger);
      await tester.pumpAndSettle();

      trigger.notifyListeners();
      await tester.pumpAndSettle();
      for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(find.text(d), findsOneWidget, reason: 'digit $d missing');
      }
    });

    testWidgets('it does nothing when shuffling is off', (tester) async {
      final trigger = ChangeNotifier();
      addTearDown(trigger.dispose);
      await _pump(tester, trigger, shuffle: KeyShuffle.none);
      await tester.pumpAndSettle();

      final before = _digitLayout(tester);
      for (var i = 0; i < 5; i++) {
        trigger.notifyListeners();
        await tester.pumpAndSettle();
      }
      expect(_digitLayout(tester), before);
    });

    testWidgets('a disposed keypad stops listening', (tester) async {
      final trigger = ChangeNotifier();
      addTearDown(trigger.dispose);
      await _pump(tester, trigger);
      await tester.pumpAndSettle();

      // Replacing the tree disposes the keypad. Firing afterwards must not
      // reach a dead State, which would throw.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
      expect(trigger.notifyListeners, returnsNormally);
    });

    testWidgets('swapping the trigger moves the subscription', (tester) async {
      final first = ChangeNotifier();
      final second = ChangeNotifier();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await _pump(tester, first);
      await tester.pumpAndSettle();
      await _pump(tester, second);
      await tester.pumpAndSettle();

      // The old one is detached, so it must not move anything.
      final before = _digitLayout(tester);
      for (var i = 0; i < 5; i++) {
        first.notifyListeners();
        await tester.pumpAndSettle();
      }
      expect(_digitLayout(tester), before);

      // The new one drives it.
      var changed = false;
      for (var i = 0; i < 12 && !changed; i++) {
        second.notifyListeners();
        await tester.pumpAndSettle();
        changed = _digitLayout(tester) != before;
      }
      expect(changed, isTrue);
    });

    testWidgets('a keypad with no trigger still works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.number,
              keyShuffle: KeyShuffle.onShow,
              onKeyPressed: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });
  });
}
