// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

void main() {
  group('Emoji And Combined Character Editing', () {
    const smile = '\u{1F600}';
    const family = '\u{1F468}‍\u{1F469}‍\u{1F467}';

    test('backspace removes a whole emoji in one press', () {
      final c = VirtualKeypadController(text: 'hi$smile');
      c.cursorPosition = c.text.length;
      c.deleteBackward();
      expect(c.text, 'hi');
      expect(c.cursorPosition, 2);
    });

    test('backspace removes a whole joined family emoji in one press', () {
      final c = VirtualKeypadController(text: 'a$family');
      c.cursorPosition = c.text.length;
      c.deleteBackward();
      expect(c.text, 'a');
    });

    test('forward delete removes a whole emoji', () {
      final c = VirtualKeypadController(text: 'a${smile}b');
      c.cursorPosition = 1;
      c.deleteForward();
      expect(c.text, 'ab');
      expect(c.cursorPosition, 1);
    });

    test('cursor steps over an emoji in one move each way', () {
      final c = VirtualKeypadController(text: 'a${smile}b');
      c.cursorPosition = 1;
      c.moveCursorRight();
      expect(c.cursorPosition, 3);
      c.moveCursorLeft();
      expect(c.cursorPosition, 1);
    });

    testWidgets(
        'backspace key in a scope removes a whole emoji without a '
        'paint error', (tester) async {
      final controller = VirtualKeypadController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VirtualKeypadScope(
            child: Column(children: [
              VirtualKeypadTextField(controller: controller),
              const VirtualKeypad(),
            ]),
          ),
        ),
      ));
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      controller.value = const TextEditingValue(
        text: 'hi$smile',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Backspace'));
      await tester.pumpAndSettle();
      expect(controller.text, 'hi');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'backspace key in standalone mode removes a whole emoji '
        'without a paint error', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            TextField(controller: controller),
            const VirtualKeypad(standalone: true),
          ]),
        ),
      ));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      controller.value = const TextEditingValue(
        text: 'hi$smile',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Backspace'));
      await tester.pumpAndSettle();
      expect(controller.text, 'hi');
      expect(tester.takeException(), isNull);
    });

    test('backspace still removes one plain letter at a time', () {
      final c = VirtualKeypadController(text: 'abc');
      c.cursorPosition = 3;
      c.deleteBackward();
      expect(c.text, 'ab');
      c.deleteBackward();
      expect(c.text, 'a');
    });

    testWidgets('maxLength counts an emoji as one character', (tester) async {
      final controller = VirtualKeypadController(text: 'ab');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VirtualKeypadScope(
            child: Column(children: [
              VirtualKeypadTextField(controller: controller, maxLength: 3),
              const VirtualKeypad(),
            ]),
          ),
        ),
      ));
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      controller.cursorPosition = 2;
      final scope = tester.state<VirtualKeypadScopeState>(
        find.byType(VirtualKeypadScope),
      );
      scope.insertText(smile);
      expect(controller.text, 'ab$smile');
      scope.insertText('c');
      expect(controller.text, 'ab$smile');

      controller.value = const TextEditingValue(
        text: 'a$smile',
        selection: TextSelection.collapsed(offset: 3),
      );
      scope.insertText('b');
      expect(controller.text, 'a${smile}b');
    });
  });
}
