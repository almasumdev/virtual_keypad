// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

Future<void> _pump(
  WidgetTester tester, {
  VirtualKeypadKeyBuilder? keyBuilder,
  KeyboardType type = KeyboardType.number,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: type,
          keyBuilder: keyBuilder,
          onKeyPressed: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('Key Builder', () {
    testWidgets('replaces the content of the keys it claims', (tester) async {
      await _pump(
        tester,
        keyBuilder: (context, info) =>
            info.label == '1' ? const Text('ONE') : null,
      );

      expect(find.text('ONE'), findsOneWidget);
      // The claimed key no longer shows its default label.
      expect(find.text('1'), findsNothing);
      // Every other key is untouched.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('returning null everywhere leaves the keyboard unchanged', (
      tester,
    ) async {
      await _pump(tester, keyBuilder: (context, info) => null);
      for (final digit in ['0', '1', '5', '9']) {
        expect(find.text(digit), findsOneWidget, reason: 'digit $digit');
      }
    });

    testWidgets('the key still works when its content is replaced', (
      tester,
    ) async {
      final pressed = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              type: KeyboardType.number,
              keyBuilder: (context, info) =>
                  info.label == '7' ? const Text('SEVEN') : null,
              onKeyPressed: (key) => pressed.add(key.text),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SEVEN'));
      await tester.pumpAndSettle();
      expect(pressed, ['7']);
    });

    testWidgets('is told the label, the key and the theme', (tester) async {
      final seen = <VirtualKeyContext>[];
      await _pump(
        tester,
        keyBuilder: (context, info) {
          seen.add(info);
          return null;
        },
      );

      expect(seen, isNotEmpty);
      final one = seen.firstWhere((i) => i.label == '1');
      expect(one.key.text, '1');
      expect(one.shift, isFalse);
      expect(one.capsLock, isFalse);
      expect(one.isFocused, isFalse);
      expect(one.theme, isA<VirtualKeypadTheme>());
    });

    testWidgets('an action key is offered with a null label', (tester) async {
      final actions = <KeyAction?>[];
      await _pump(
        tester,
        keyBuilder: (context, info) {
          if (info.label == null) actions.add(info.key.action);
          return null;
        },
      );
      expect(actions, isNotEmpty);
      expect(actions, contains(KeyAction.backSpace));
    });

    testWidgets('a builder can replace an action key by its action', (
      tester,
    ) async {
      await _pump(
        tester,
        keyBuilder: (context, info) =>
            info.key.action == KeyAction.backSpace ? const Text('DEL') : null,
      );
      expect(find.text('DEL'), findsOneWidget);
    });

    testWidgets('the label follows shift on a text layout', (tester) async {
      final labels = <String>{};
      await _pump(
        tester,
        type: KeyboardType.text,
        keyBuilder: (context, info) {
          if (info.label != null) labels.add(info.label!);
          return null;
        },
      );
      // Unshifted to begin with.
      expect(labels.contains('a'), isTrue);
      expect(labels.contains('A'), isFalse);

      labels.clear();
      await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
      await tester.pumpAndSettle();
      expect(labels.contains('A'), isTrue);
    });
  });
}
