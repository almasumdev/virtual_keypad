import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/src/widgets/emoji_dpad_view.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Builds a keypad on its emoji page, with D-pad navigation either on or off.
Future<void> _pump(
  WidgetTester tester, {
  required bool dpad,
  List<String> pressed = const [],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: KeyboardType.text,
          enableEmojiKey: true,
          showEmojiKeyboardInitially: true,
          enableDpadNavigation: dpad,
          onKeyPressedWithText: (_, text) {
            if (text != null) pressed.add(text);
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Sends one key down and up, as a remote would.
Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await simulateKeyDownEvent(key);
  await simulateKeyUpEvent(key);
  await tester.pumpAndSettle();
}

/// The emoji currently under the grid's cursor, read from the highlight.
String? _cursorEmoji(WidgetTester tester) {
  final highlighted = find.byWidgetPredicate((w) {
    if (w is! Container) return false;
    final d = w.decoration;
    return d is BoxDecoration &&
        d.color != null &&
        d.color != Colors.transparent;
  });
  for (final element in highlighted.evaluate()) {
    final text = find.descendant(
      of: find.byWidget(element.widget),
      matching: find.byType(Text),
    );
    final found = text.evaluate();
    if (found.isEmpty) continue;
    final data = (found.first.widget as Text).data;
    // Category tiles hold an icon, not text, so only the grid matches here.
    if (data != null && data.isNotEmpty) return data;
  }
  return null;
}

void main() {
  group('Emoji D-Pad View', () {
    testWidgets('the grid appears only when D-pad navigation is on', (
      tester,
    ) async {
      await _pump(tester, dpad: false);
      expect(find.byType(EmojiDpadView), findsNothing);

      await _pump(tester, dpad: true);
      expect(find.byType(EmojiDpadView), findsOneWidget);
    });

    testWidgets('arrow down moves off the category strip into the grid', (
      tester,
    ) async {
      await _pump(tester, dpad: true);
      // Nothing in the grid is highlighted until the cursor drops into it.
      expect(_cursorEmoji(tester), isNull);

      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_cursorEmoji(tester), isNotNull);
    });

    testWidgets('arrow right moves along the row', (tester) async {
      await _pump(tester, dpad: true);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      final first = _cursorEmoji(tester);

      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(_cursorEmoji(tester), isNot(first));
    });

    testWidgets('arrow left comes back to where it started', (tester) async {
      await _pump(tester, dpad: true);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      final first = _cursorEmoji(tester);

      await _press(tester, LogicalKeyboardKey.arrowRight);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(_cursorEmoji(tester), first);
    });

    testWidgets('arrow down moves a whole row, not one cell', (tester) async {
      await _pump(tester, dpad: true);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      final first = _cursorEmoji(tester);

      await _press(tester, LogicalKeyboardKey.arrowRight);
      final second = _cursorEmoji(tester);

      await _press(tester, LogicalKeyboardKey.arrowDown);
      final below = _cursorEmoji(tester);
      // A row step lands on neither of the two cells beside the start.
      expect(below, isNot(first));
      expect(below, isNot(second));
    });

    testWidgets('arrow up from the top row returns to the category strip', (
      tester,
    ) async {
      await _pump(tester, dpad: true);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_cursorEmoji(tester), isNotNull);

      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_cursorEmoji(tester), isNull);
    });

    testWidgets('select inserts the emoji under the cursor', (tester) async {
      final pressed = <String>[];
      await _pump(tester, dpad: true, pressed: pressed);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      final under = _cursorEmoji(tester);

      await _press(tester, LogicalKeyboardKey.select);
      expect(pressed, hasLength(1));
      expect(pressed.single, under);
    });

    testWidgets('enter selects as well, for a remote that sends it', (
      tester,
    ) async {
      final pressed = <String>[];
      await _pump(tester, dpad: true, pressed: pressed);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(pressed, hasLength(1));
    });

    testWidgets('select on the category strip drops into the grid', (
      tester,
    ) async {
      final pressed = <String>[];
      await _pump(tester, dpad: true, pressed: pressed);
      // The cursor starts on the strip, so this should move rather than insert.
      await _press(tester, LogicalKeyboardKey.select);
      expect(pressed, isEmpty);
      expect(_cursorEmoji(tester), isNotNull);
    });

    testWidgets('moving right on the strip changes category', (tester) async {
      await _pump(tester, dpad: true);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      final firstCategoryEmoji = _cursorEmoji(tester);

      // Back to the strip, one category across, then into the grid again.
      await _press(tester, LogicalKeyboardKey.arrowUp);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_cursorEmoji(tester), isNot(firstCategoryEmoji));
    });

    testWidgets('arrow up from the strip leaves the emoji page', (
      tester,
    ) async {
      await _pump(tester, dpad: true);
      expect(find.byType(EmojiDpadView), findsOneWidget);

      // The cursor is on the strip, so travelling up again closes the page.
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(find.byType(EmojiDpadView), findsNothing);
    });

    testWidgets('tapping an emoji still works with the D-pad view', (
      tester,
    ) async {
      final pressed = <String>[];
      await _pump(tester, dpad: true, pressed: pressed);
      // The grid stays a touch target, so a phone with a remote attached
      // behaves the same way either side.
      final grid = find.byType(GridView);
      expect(grid, findsOneWidget);
      final anyEmoji = find.descendant(of: grid, matching: find.byType(Text));
      await tester.tap(anyEmoji.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(pressed, hasLength(1));
    });
  });
}
