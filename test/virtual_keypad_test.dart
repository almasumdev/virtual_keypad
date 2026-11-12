import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VirtualKeypadController', () {
    test('insertText adds text at cursor position', () {
      final controller = VirtualKeypadController();
      controller.insertText('Hello');
      expect(controller.text, 'Hello');
      expect(controller.cursorPosition, 5);
    });

    test('deleteBackward removes character before cursor', () {
      final controller = VirtualKeypadController(text: 'Hello');
      controller.cursorPosition = 5;
      controller.deleteBackward();
      expect(controller.text, 'Hell');
      expect(controller.cursorPosition, 4);
    });

    test('clear removes all text', () {
      final controller = VirtualKeypadController(text: 'Hello');
      controller.clear();
      expect(controller.text, '');
      expect(controller.cursorPosition, 0);
    });

    test('insertText at middle position', () {
      final controller = VirtualKeypadController(text: 'Helo');
      controller.cursorPosition = 3;
      controller.insertText('l');
      expect(controller.text, 'Hello');
      expect(controller.cursorPosition, 4);
    });

    test('selectAll selects entire text', () {
      final controller = VirtualKeypadController(text: 'Hello');
      controller.selectAll();
      expect(controller.selection.start, 0);
      expect(controller.selection.end, 5);
      expect(controller.selection.isCollapsed, false);
    });

    test('insertText replaces selection', () {
      final controller = VirtualKeypadController(text: 'Hello World');
      // Select "World"
      controller.selection = const TextSelection(
        baseOffset: 6,
        extentOffset: 11,
      );
      controller.insertText('Flutter');
      expect(controller.text, 'Hello Flutter');
      expect(controller.cursorPosition, 13);
    });

    test('deleteBackward removes selection', () {
      final controller = VirtualKeypadController(text: 'Hello World');
      // Select "World"
      controller.selection = const TextSelection(
        baseOffset: 6,
        extentOffset: 11,
      );
      controller.deleteBackward();
      expect(controller.text, 'Hello ');
      expect(controller.cursorPosition, 6);
    });

    test('deleteForward removes character after cursor', () {
      final controller = VirtualKeypadController(text: 'Hello');
      controller.cursorPosition = 1;

      controller.deleteForward();

      expect(controller.text, 'Hllo');
      expect(controller.cursorPosition, 1);
    });

    test('cursor position falls back to text length for range selection', () {
      final controller = VirtualKeypadController(text: 'Hello');
      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 4,
      );

      expect(controller.cursorPosition, 5);
    });

    test('cursor helpers clamp and move within bounds', () {
      final controller = VirtualKeypadController(text: 'Hello');

      controller.cursorPosition = -10;
      expect(controller.cursorPosition, 0);

      controller.moveCursorRight();
      expect(controller.cursorPosition, 1);

      controller.moveCursorToEnd();
      expect(controller.cursorPosition, 5);

      controller.moveCursorLeft();
      expect(controller.cursorPosition, 4);

      controller.moveCursorToStart();
      expect(controller.cursorPosition, 0);

      controller.cursorPosition = 99;
      expect(controller.cursorPosition, 5);
    });

    test('range helpers ignore invalid bounds and insert at collapsed range',
        () {
      final controller = VirtualKeypadController(text: 'Hello');

      controller.deleteRange(-1, 2);
      controller.deleteRange(4, 2);
      controller.replaceRange(10, 11, '!');
      expect(controller.text, 'Hello');

      controller.replaceRange(2, 2, 'yy');
      expect(controller.text, 'Heyyllo');
      expect(controller.cursorPosition, 4);
    });
  });

  group('StandaloneInputControl', () {
    test('insertText modifies current value', () {
      final control = StandaloneInputControl();
      // Simulate attach with initial empty value
      control.setEditingState(
        TextEditingValue.empty.copyWith(
          selection: const TextSelection.collapsed(offset: 0),
        ),
      );
      control.insertText('Hi');
      expect(control.currentValue.text, 'Hi');
      expect(control.currentValue.selection.baseOffset, 2);
    });

    test('deleteBackward removes character', () {
      final control = StandaloneInputControl();
      control.setEditingState(
        const TextEditingValue(
          text: 'Hello',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      control.deleteBackward();
      expect(control.currentValue.text, 'Hell');
      expect(control.currentValue.selection.baseOffset, 4);
    });

    test('deleteBackward removes selection', () {
      final control = StandaloneInputControl();
      control.setEditingState(
        const TextEditingValue(
          text: 'Hello World',
          selection: TextSelection(baseOffset: 5, extentOffset: 11),
        ),
      );
      control.deleteBackward();
      expect(control.currentValue.text, 'Hello');
      expect(control.currentValue.selection.baseOffset, 5);
    });

    test('insertText replaces selection', () {
      final control = StandaloneInputControl();
      control.setEditingState(
        const TextEditingValue(
          text: 'Hello World',
          selection: TextSelection(baseOffset: 6, extentOffset: 11),
        ),
      );
      control.insertText('Flutter');
      expect(control.currentValue.text, 'Hello Flutter');
      expect(control.currentValue.selection.baseOffset, 13);
    });

    test('keyboardType defaults to text', () {
      final control = StandaloneInputControl();
      expect(control.keyboardType, KeyboardType.text);
    });

    test('isAttached tracks attach/detach', () {
      final control = StandaloneInputControl();
      expect(control.isAttached, false);
    });
  });

  group('VirtualKey', () {
    test('character key returns correct display text', () {
      final key = VirtualKey.character(text: 'a');
      expect(key.getDisplayText(), 'a');
      expect(key.getDisplayText(shift: true), 'A');
      expect(key.getDisplayText(capsLock: true), 'A');
    });

    test('action key is identified correctly', () {
      final key = VirtualKey.action(action: KeyAction.backSpace);
      expect(key.isAction, true);
      expect(key.isCharacter, false);
    });

    test('action keys return the correct insert text', () {
      expect(
        VirtualKey.action(action: KeyAction.space).getInsertText(),
        ' ',
      );
      expect(
        VirtualKey.action(action: KeyAction.enter).getInsertText(),
        '\n',
      );
      expect(
        VirtualKey.action(action: KeyAction.done).getInsertText(),
        '',
      );
      expect(
        VirtualKey.action(action: KeyAction.shift).getDisplayText(),
        '',
      );
    });
  });

  group('VirtualKeypadTheme', () {
    test('copyWith overrides selected fields and preserves others', () {
      const baseTheme = VirtualKeypadTheme.dark;

      final updatedTheme = baseTheme.copyWith(
        keyTextSize: 28,
        keyBorderRadius: 14,
        keyShadow: false,
      );

      expect(updatedTheme.backgroundColor, baseTheme.backgroundColor);
      expect(updatedTheme.keyTextSize, 28);
      expect(updatedTheme.keyBorderRadius, 14);
      expect(updatedTheme.keyShadow, isFalse);
      expect(updatedTheme.keyColor, baseTheme.keyColor);
    });

    test('decorations omit shadows when disabled', () {
      const theme = VirtualKeypadTheme(keyShadow: false);

      expect(theme.keyDecoration.boxShadow, isNull);
      expect(theme.actionKeyDecoration.boxShadow, isNull);
    });
  });

  group('VirtualKeypadTextField configuration', () {
    testWidgets('defaults to virtual-only input with enforced max length', (
      tester,
    ) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: VirtualKeypadTextField(
                controller: controller,
                keyboardType: KeyboardType.emailAddress,
                maxLength: 4,
              ),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.readOnly, isTrue);
      expect(textField.showCursor, isTrue);
      expect(textField.keyboardType, TextInputType.none);
      expect(textField.maxLengthEnforcement, MaxLengthEnforcement.enforced);
    });

    testWidgets('allows physical keyboard and maps Flutter keyboard type', (
      tester,
    ) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: VirtualKeypadTextField(
                controller: controller,
                allowPhysicalKeyboard: true,
                keyboardType: KeyboardType.numberDecimal,
              ),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.readOnly, isFalse);
      expect(
        textField.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
      expect(textField.maxLengthEnforcement, MaxLengthEnforcement.none);
    });

    testWidgets('explicit readOnly hides the cursor', (tester) async {
      final controller = VirtualKeypadController(text: 'secret');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: VirtualKeypadTextField(
                controller: controller,
                allowPhysicalKeyboard: true,
                readOnly: true,
                keyboardType: KeyboardType.name,
              ),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.readOnly, isTrue);
      expect(textField.showCursor, isFalse);
      expect(textField.keyboardType, TextInputType.name);
    });
  });

  group('VirtualKeypadStandaloneScope', () {
    testWidgets('maybeOf returns null when no scope in tree', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(VirtualKeypadStandaloneScope.maybeOf(capturedContext), isNull);
    });

    testWidgets('maybeOf returns state when scope is ancestor', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: VirtualKeypadStandaloneScope(
            child: Builder(
              builder: (ctx) {
                capturedContext = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(
        VirtualKeypadStandaloneScope.maybeOf(capturedContext),
        isA<VirtualKeypadStandaloneScopeState>(),
      );
    });

    testWidgets('two sibling scopes return different state instances', (
      tester,
    ) async {
      late BuildContext contextA;
      late BuildContext contextB;
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              VirtualKeypadStandaloneScope(
                child: Builder(
                  builder: (ctx) {
                    contextA = ctx;
                    return const SizedBox.shrink();
                  },
                ),
              ),
              VirtualKeypadStandaloneScope(
                child: Builder(
                  builder: (ctx) {
                    contextB = ctx;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );
      final scopeA = VirtualKeypadStandaloneScope.maybeOf(contextA);
      final scopeB = VirtualKeypadStandaloneScope.maybeOf(contextB);
      expect(scopeA, isNotNull);
      expect(scopeB, isNotNull);
      expect(scopeA, isNot(same(scopeB)));
    });
  });

  group('VirtualKeypad form navigation', () {
    testWidgets('next action moves focus to the next scoped field', (
      tester,
    ) async {
      final firstController = VirtualKeypadController();
      final secondController = VirtualKeypadController();
      var firstSubmitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: firstController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => firstSubmitted = true,
                  ),
                  VirtualKeypadTextField(
                    controller: secondController,
                    textInputAction: TextInputAction.done,
                  ),
                  const VirtualKeypad(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).at(0));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(0))
            .focusNode
            ?.hasFocus,
        isTrue,
      );

      await tester.tap(find.byIcon(Icons.keyboard_tab));
      await tester.pumpAndSettle();

      expect(firstSubmitted, isTrue);
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(0))
            .focusNode
            ?.hasFocus,
        isFalse,
      );
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(1))
            .focusNode
            ?.hasFocus,
        isTrue,
      );
    });

    testWidgets('previous action moves focus to the previous scoped field', (
      tester,
    ) async {
      final firstController = VirtualKeypadController();
      final secondController = VirtualKeypadController();
      var secondSubmitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: firstController,
                    textInputAction: TextInputAction.done,
                  ),
                  VirtualKeypadTextField(
                    controller: secondController,
                    textInputAction: TextInputAction.previous,
                    onSubmitted: (_) => secondSubmitted = true,
                  ),
                  const VirtualKeypad(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).at(1));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(1))
            .focusNode
            ?.hasFocus,
        isTrue,
      );

      await tester.tap(find.byIcon(Icons.keyboard_tab));
      await tester.pumpAndSettle();

      expect(secondSubmitted, isTrue);
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(0))
            .focusNode
            ?.hasFocus,
        isTrue,
      );
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(1))
            .focusNode
            ?.hasFocus,
        isFalse,
      );
    });
  });

  group('VirtualKeypad action handling', () {
    testWidgets('custom search action reports the pressed action', (
      tester,
    ) async {
      final controller = VirtualKeypadController(text: 'query');
      KeyAction? action;
      String? submittedText;
      var submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: controller,
                    onInputAction: (pressedAction, text) {
                      action = pressedAction;
                      submittedText = text;
                    },
                    onSubmitted: (_) => submitted = true,
                  ),
                  VirtualKeypad(
                    type: KeyboardType.custom,
                    customLayout: [
                      [VirtualKey.action(action: KeyAction.search)],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(action, KeyAction.search);
      expect(submittedText, 'query');
      expect(submitted, isTrue);
    });

    testWidgets('custom call action reports the pressed action',
        (tester) async {
      final controller = VirtualKeypadController(text: '5551234');
      KeyAction? action;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: controller,
                    onInputAction: (pressedAction, _) {
                      action = pressedAction;
                    },
                  ),
                  VirtualKeypad(
                    type: KeyboardType.custom,
                    customLayout: [
                      [VirtualKey.action(action: KeyAction.call)],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();

      expect(action, KeyAction.call);
    });
  });

  group('VirtualKeypad accessibility', () {
    testWidgets('action keys expose semantic labels and hints', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      try {
        final firstController = VirtualKeypadController();
        final secondController = VirtualKeypadController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VirtualKeypadScope(
                child: Column(
                  children: [
                    VirtualKeypadTextField(
                      controller: firstController,
                      textInputAction: TextInputAction.next,
                    ),
                    VirtualKeypadTextField(controller: secondController),
                    const VirtualKeypad(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField).first);
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Backspace')),
          matchesSemantics(
            label: 'Backspace',
            hint: 'Deletes the previous character. Long press to repeat.',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Next field')),
          matchesSemantics(
            label: 'Next field',
            hint: 'Moves focus to the next field.',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );
      } finally {
        semanticsHandle.dispose();
      }
    });

    testWidgets('shift key announces its current state', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      try {
        final controller = VirtualKeypadController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VirtualKeypadScope(
                child: Column(
                  children: [
                    VirtualKeypadTextField(controller: controller),
                    const VirtualKeypad(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField).first);
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Shift')),
          matchesSemantics(
            label: 'Shift',
            value: 'Off',
            hint: 'Turns uppercase on for the next character.',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );

        await tester.tap(find.byIcon(Icons.arrow_upward_outlined));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Shift')),
          matchesSemantics(
            label: 'Shift',
            value: 'On',
            hint: 'Turns caps lock on.',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );
      } finally {
        semanticsHandle.dispose();
      }
    });
  });

  group('VirtualKeypad standalone actions', () {
    testWidgets('custom call action reports through standalone callback', (
      tester,
    ) async {
      final controller = TextEditingController(text: '5551234');
      KeyAction? action;
      String? submittedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(controller: controller),
                VirtualKeypad(
                  standalone: true,
                  type: KeyboardType.custom,
                  customLayout: [
                    [VirtualKey.action(action: KeyAction.call)],
                  ],
                  onStandaloneInputAction: (pressedAction, text) {
                    action = pressedAction;
                    submittedText = text;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();

      expect(action, KeyAction.call);
      expect(submittedText, '5551234');
    });
  });

  group('VirtualKeypadFloating', () {
    testWidgets('supports standalone TextField input in floating mode', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                standalone: true,
                width: 280,
                type: KeyboardType.custom,
                customLayout: [
                  [VirtualKey.character(text: '1')],
                ],
                child: Column(
                  children: [TextField(controller: controller)],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(controller.text, '1');
    });

    testWidgets('supports scoped VirtualKeypadTextField input in floating mode',
        (
      tester,
    ) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadScope(
                child: VirtualKeypadFloating(
                  width: 280,
                  type: KeyboardType.custom,
                  customLayout: [
                    [VirtualKey.character(text: 'A')],
                  ],
                  child: Column(
                    children: [
                      VirtualKeypadTextField(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(controller.text, 'A');
    });

    testWidgets('dock controls reposition the floating panel', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                standalone: true,
                width: 280,
                type: KeyboardType.custom,
                customLayout: [
                  [VirtualKey.character(text: '1')],
                ],
                child: Column(
                  children: [TextField(focusNode: focusNode)],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final panelFinder = find.byKey(
        const ValueKey('virtual_keypad_floating_panel'),
      );
      final initialTop = tester.getTopLeft(panelFinder).dy;

      await tester.tap(find.byTooltip('Dock to top'));
      await tester.pumpAndSettle();
      final topDocked = tester.getTopLeft(panelFinder).dy;

      await tester.tap(find.byTooltip('Dock to bottom'));
      await tester.pumpAndSettle();
      final bottomDocked = tester.getTopLeft(panelFinder).dy;

      expect(topDocked, lessThan(initialTop));
      expect(bottomDocked, greaterThan(topDocked));
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('close button unfocuses the active field', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                standalone: true,
                width: 280,
                type: KeyboardType.custom,
                customLayout: [
                  [VirtualKey.character(text: '1')],
                ],
                child: Column(
                  children: [TextField(focusNode: focusNode)],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);

      await tester.tap(find.byTooltip('Close keyboard'));
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets('persistent mode stays visible until controller hides it', (
      tester,
    ) async {
      final controller = VirtualKeypadFloatingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                controller: controller,
                visibilityMode: VirtualKeypadFloatingVisibilityMode.persistent,
                standalone: true,
                width: 280,
                type: KeyboardType.custom,
                customLayout: [
                  [VirtualKey.character(text: '1')],
                ],
                child: const Column(
                  children: [TextField()],
                ),
              ),
            ),
          ),
        ),
      );

      final panelFinder = find.byKey(
        const ValueKey('virtual_keypad_floating_panel'),
      );
      final ignorePointerFinder = find.ancestor(
        of: panelFinder,
        matching: find.byType(IgnorePointer),
      );

      expect(
        tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
        isTrue,
      );

      controller.show();
      await tester.pumpAndSettle();

      expect(
        tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
        isFalse,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(
        tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
        isFalse,
      );

      controller.hide();
      await tester.pumpAndSettle();

      expect(
        tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
        isTrue,
      );
    });

    testWidgets('applies floating panel theme and border radius', (
      tester,
    ) async {
      const customTheme = VirtualKeypadTheme(
        backgroundColor: Color(0xFF102A43),
        keyColor: Color(0xFF1F4068),
        actionKeyColor: Color(0xFF3E7CB1),
        keyTextColor: Colors.white,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                standalone: true,
                width: 280,
                borderRadius: 26,
                theme: customTheme,
                type: KeyboardType.custom,
                customLayout: [
                  [VirtualKey.character(text: '1')],
                ],
                child: const Column(
                  children: [TextField()],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final panelFinder = find.byKey(
        const ValueKey('virtual_keypad_floating_panel'),
      );
      final panelMaterial = tester.widget<Material>(panelFinder);
      final clipFinder = find.ancestor(
        of: panelFinder,
        matching: find.byType(ClipRRect),
      );
      final clip = tester.widget<ClipRRect>(clipFinder.first);
      final borderRadius = clip.borderRadius as BorderRadius;

      expect(panelMaterial.color, customTheme.backgroundColor);
      expect(borderRadius.topLeft.x, 26);
      expect(borderRadius.bottomRight.x, 26);
    });

    testWidgets('language picker keeps floating keyboard visible', (
      tester,
    ) async {
      final provider = KeyboardLayoutProvider.instance;
      addTearDown(provider.reset);
      provider.reset();
      initializeKeyboardLayouts();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                standalone: true,
                width: 320,
                availableLanguages: ['en', 'bn'],
                child: Column(
                  children: [TextField()],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final panelFinder = find.byKey(
        const ValueKey('virtual_keypad_floating_panel'),
      );
      final ignorePointerFinder = find.ancestor(
        of: panelFinder,
        matching: find.byType(IgnorePointer),
      );

      expect(tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
          isFalse);

      await tester.longPress(find.text('space'));
      await tester.pumpAndSettle();

      expect(find.text('বাংলা'), findsOneWidget);
      expect(tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
          isFalse);

      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();

      expect(provider.currentLanguageCode, 'bn');
      expect(tester.widget<IgnorePointer>(ignorePointerFinder.first).ignoring,
          isFalse);
    });
  });

  group('VirtualKeypad configuration', () {
    final customLayout = <KeyRow>[
      [VirtualKey.character(text: '1')],
    ];

    test('requires customLayout when type is custom', () {
      expect(
        () => VirtualKeypad(type: KeyboardType.custom),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects customLayout when type is not custom', () {
      expect(
        () => VirtualKeypad(customLayout: customLayout),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () =>
            VirtualKeypad(type: KeyboardType.text, customLayout: customLayout),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('KeyboardLayoutProvider validation', () {
    final provider = KeyboardLayoutProvider.instance;

    setUp(() {
      provider.reset();
    });

    tearDown(() {
      provider.reset();
    });

    test('rejects languages with an empty code', () {
      expect(
        () => provider.registerLanguage(
          KeyboardLanguage(
            code: '',
            name: 'Invalid',
            nativeName: 'Invalid',
            textLayouts: KeyboardLayoutSet.single([
              [VirtualKey.character(text: 'a')],
            ]),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects languages with empty layout rows', () {
      expect(
        () => provider.registerLanguage(
          const KeyboardLanguage(
            code: 'xx',
            name: 'Invalid',
            nativeName: 'Invalid',
            textLayouts: KeyboardLayoutSet.single([
              [],
            ]),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects languages with non-positive key flex', () {
      expect(
        () => provider.registerLanguage(
          KeyboardLanguage(
            code: 'yy',
            name: 'Invalid',
            nativeName: 'Invalid',
            textLayouts: KeyboardLayoutSet.single([
              [VirtualKey.character(text: 'a', flex: 0)],
            ]),
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('VirtualKeypad language switching', () {
    final provider = KeyboardLayoutProvider.instance;

    setUp(() {
      provider.reset();
      initializeKeyboardLayouts();
    });

    tearDown(() {
      provider.reset();
    });

    testWidgets('initialLanguage seeds the runtime language', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: VirtualKeypadController(),
                  ),
                  const VirtualKeypad(
                    availableLanguages: ['en', 'bn'],
                    initialLanguage: 'bn',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(provider.currentLanguageCode, 'bn');
    });

    testWidgets('long-pressing space opens picker and changes language', (
      tester,
    ) async {
      String? changedLanguage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: VirtualKeypadController(),
                  ),
                  VirtualKeypad(
                    availableLanguages: const ['en', 'bn'],
                    onLanguageChanged: (code) {
                      changedLanguage = code;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      await tester.longPress(find.text('space'));
      await tester.pumpAndSettle();

      expect(find.text('বাংলা'), findsOneWidget);

      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();

      expect(provider.currentLanguageCode, 'bn');
      expect(changedLanguage, 'bn');
    });

    testWidgets('explicit language selection persists across widget rebuilds', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: VirtualKeypadController(),
                  ),
                  const VirtualKeypad(
                    availableLanguages: ['en', 'bn'],
                    initialLanguage: 'en',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.longPress(find.text('space'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();

      expect(provider.currentLanguageCode, 'bn');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(
                    controller: VirtualKeypadController(),
                  ),
                  const VirtualKeypad(
                    availableLanguages: ['en', 'bn'],
                    initialLanguage: 'en',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(provider.currentLanguageCode, 'bn');
    });
  });

  group('VirtualKeypad emoji support', () {
    testWidgets('emoji key opens emoji layout and inserts emoji',
        (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(enableEmojiKey: true),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Show emoji'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Show emoji'));
      await tester.pumpAndSettle();

      expect(find.byType(emoji_picker.EmojiPicker), findsOneWidget);
      expect(find.byKey(const Key('emojiScrollView')), findsOneWidget);
      final emojiCellFinder = find.byType(emoji_picker.EmojiCell).hitTestable();
      expect(emojiCellFinder, findsWidgets);
      final firstEmojiTextFinder = find.descendant(
        of: emojiCellFinder.first,
        matching: find.byType(Text),
      );
      final firstEmoji = tester.widget<Text>(firstEmojiTextFinder.first).data!;
      expect(find.text('q'), findsNothing);

      await tester.tap(emojiCellFinder.first);
      await tester.pumpAndSettle();

      expect(controller.text, firstEmoji);

      await tester.tap(find.text('ABC'));
      await tester.pumpAndSettle();

      expect(find.text('q'), findsOneWidget);
    });

    testWidgets(
      'standalone emoji picker stays visible and disables skin tones',
      (
        tester,
      ) async {
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(focusNode: focusNode),
                  const Spacer(),
                  const VirtualKeypad(
                    standalone: true,
                    hideWhenUnfocused: true,
                    enableEmojiKey: true,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Show emoji'));
        await tester.pumpAndSettle();

        final picker = tester.widget<emoji_picker.EmojiPicker>(
          find.byType(emoji_picker.EmojiPicker),
        );
        expect(picker.config.skinToneConfig.enabled, isFalse);

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        expect(find.byType(emoji_picker.EmojiPicker), findsOneWidget);
      },
    );

    testWidgets('emoji keyboard can be shown by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(),
                Spacer(),
                VirtualKeypad(
                  standalone: true,
                  hideWhenUnfocused: false,
                  enableEmojiKey: true,
                  showEmojiKeyboardInitially: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byType(emoji_picker.EmojiPicker), findsOneWidget);
      expect(find.text('q'), findsNothing);
    });

    testWidgets('emoji keyboard can be shown by default without focus', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VirtualKeypad(
              hideWhenUnfocused: false,
              enableEmojiKey: true,
              showEmojiKeyboardInitially: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(emoji_picker.EmojiPicker), findsOneWidget);
      expect(find.text('q'), findsNothing);
    });

    testWidgets('constrained standalone keyboard does not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 420,
                child: Column(
                  children: [
                    TextField(),
                    Spacer(),
                    VirtualKeypad(
                      standalone: true,
                      hideWhenUnfocused: true,
                      enableEmojiKey: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('emojiTextStyle reaches the emoji picker config',
        (tester) async {
      const style = TextStyle(fontFamily: 'NotoEmoji', fontSize: 30);
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(
                    enableEmojiKey: true,
                    emojiTextStyle: style,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Show emoji'));
      await tester.pumpAndSettle();

      final picker = tester.widget<emoji_picker.EmojiPicker>(
          find.byType(emoji_picker.EmojiPicker));
      expect(picker.config.emojiTextStyle, style);
    });

    testWidgets('emoji style defaults to the platform font off the web',
        (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(enableEmojiKey: true),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Show emoji'));
      await tester.pumpAndSettle();

      final picker = tester.widget<emoji_picker.EmojiPicker>(
          find.byType(emoji_picker.EmojiPicker));

      if (kIsWeb) {
        expect(
          picker.config.emojiTextStyle?.fontFamily,
          kBundledEmojiFontFamily,
        );
      } else {
        // The platform's own color emoji font is left in place.
        expect(picker.config.emojiTextStyle, isNull);
      }
    });

    test('bundled emoji font family is package qualified', () {
      expect(kBundledEmojiFontFamily, 'packages/virtual_keypad/NotoEmoji');
    });

    test('emoji font helpers follow the platform', () {
      const style = TextStyle(fontSize: 18);
      final theme = ThemeData.light();

      if (kIsWeb) {
        // Web has no system emoji font to fall back on, so the bundled one
        // has to be applied or emoji render blank until a download lands.
        expect(defaultEmojiTextStyle()?.fontFamily, kBundledEmojiFontFamily);
        expect(
          withBundledEmojiFallback(style)?.fontFamilyFallback,
          contains(kBundledEmojiFontFamily),
        );
        expect(withBundledEmojiFallback(style)?.fontSize, 18);
        expect(
          theme
              .withVirtualKeypadEmojiFont()
              .textTheme
              .bodyMedium
              ?.fontFamilyFallback,
          contains(kBundledEmojiFontFamily),
        );
      } else {
        // Guards against the bundled monochrome font ever overriding the
        // platform's color emoji font on Android, iOS, or desktop.
        expect(defaultEmojiTextStyle(), isNull);
        expect(withBundledEmojiFallback(style), same(style));
        expect(withBundledEmojiFallback(null), isNull);
        expect(theme.withVirtualKeypadEmojiFont(), same(theme));
      }
    });

    testWidgets('VirtualKeypadTextField adds the emoji fallback only on web',
        (tester) async {
      final controller = VirtualKeypadController();
      const style = TextStyle(fontSize: 21, color: Colors.teal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: VirtualKeypadTextField(
                controller: controller,
                style: style,
              ),
            ),
          ),
        ),
      );

      final applied = tester.widget<TextField>(find.byType(TextField)).style;

      if (kIsWeb) {
        expect(applied?.fontFamilyFallback, contains(kBundledEmojiFontFamily));
        // The caller's own styling has to survive the fallback being added.
        expect(applied?.fontSize, 21);
        expect(applied?.color, Colors.teal);
      } else {
        expect(applied, style);
      }
    });

    testWidgets('emoji platform compatibility check is off by default',
        (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(enableEmojiKey: true),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Show emoji'));
      await tester.pumpAndSettle();

      final picker = tester.widget<emoji_picker.EmojiPicker>(
          find.byType(emoji_picker.EmojiPicker));
      expect(picker.config.checkPlatformCompatibility, isFalse);
    });

    testWidgets('emoji platform compatibility check can be opted into',
        (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(
                    enableEmojiKey: true,
                    checkEmojiPlatformCompatibility: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Show emoji'));
      await tester.pumpAndSettle();

      final picker = tester.widget<emoji_picker.EmojiPicker>(
          find.byType(emoji_picker.EmojiPicker));
      expect(picker.config.checkPlatformCompatibility, isTrue);
    });
  });

  group('VirtualKeypadColorEmoji', () {
    setUp(VirtualKeypadColorEmoji.resetForTesting);
    tearDown(VirtualKeypadColorEmoji.resetForTesting);

    test('a failing loader falls back instead of throwing', () async {
      await expectLater(
        VirtualKeypadColorEmoji.load(
          () => Future<ByteData>.error(StateError('offline')),
        ),
        completion(isFalse),
      );

      // The bundled monochrome font stays in place, so emoji still render.
      expect(VirtualKeypadColorEmoji.isLoaded.value, isFalse);
    });

    test('rejects bytes that are not a font', () async {
      // A captive portal or a 404 page served in place of the font. FontLoader
      // would happily register this and leave emoji blank.
      final html = ByteData.sublistView(
        Uint8List.fromList('<!doctype html><title>404</title>'.codeUnits),
      );

      await expectLater(
        VirtualKeypadColorEmoji.load(() async => html),
        completion(isFalse),
      );
      expect(VirtualKeypadColorEmoji.isLoaded.value, isFalse);
    });

    test('rejects WOFF2, which Flutter cannot load', () async {
      final woff2 = ByteData.sublistView(
        Uint8List.fromList([0x77, 0x4F, 0x46, 0x32, 0, 0, 0, 0]),
      );

      await expectLater(
        VirtualKeypadColorEmoji.load(() async => woff2),
        completion(isFalse),
      );
    });

    testWidgets('emoji columns scale with width to keep density steady',
        (tester) async {
      Future<int> columnsAt(double width) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final controller = VirtualKeypadController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VirtualKeypadScope(
                child: Column(
                  children: [
                    VirtualKeypadTextField(controller: controller),
                    const VirtualKeypad(enableEmojiKey: true),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(TextField).first);
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Show emoji'));
        await tester.pumpAndSettle();

        final columns = tester
            .widget<emoji_picker.EmojiPicker>(
                find.byType(emoji_picker.EmojiPicker))
            .config
            .emojiViewConfig
            .columns;

        await tester.pumpWidget(const SizedBox.shrink());
        return columns;
      }

      final narrow = await columnsAt(380);
      final wide = await columnsAt(1900);

      // The old fixed ladder capped at 12, which left ~158px cells around a
      // ~30px glyph on a full-width desktop keyboard.
      expect(narrow, greaterThanOrEqualTo(7));
      expect(wide, greaterThan(narrow * 2));
      expect(wide, lessThanOrEqualTo(32));
    });

    test('fallback chain ends with the monochrome font', () {
      // Monochrome must stay last, since it is what guarantees emoji render.
      expect(bundledEmojiFallbackFamilies().last, kBundledEmojiFontFamily);
    });

    testWidgets('no loader means nothing is fetched', (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(enableEmojiKey: true),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(VirtualKeypadColorEmoji.isLoaded.value, isFalse);
    });

    testWidgets('loader runs only on the web', (tester) async {
      var called = false;
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  VirtualKeypad(
                    enableEmojiKey: true,
                    colorEmojiFontLoader: () async {
                      called = true;
                      // Rejected by the signature check, which is fine: this
                      // asserts whether the loader ran, not what it returned.
                      return ByteData(4);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Native platforms already render color emoji from the system font, so
      // fetching one there would be wasted bytes.
      expect(called, kIsWeb);
    });
  });

  group('VirtualKeypad D-pad navigation', () {
    Future<VirtualKeypadController> pumpKeypad(
      WidgetTester tester, {
      required bool dpad,
    }) async {
      final controller = VirtualKeypadController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  VirtualKeypad(enableDpadNavigation: dpad),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      return controller;
    }

    Future<void> send(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('select presses the highlighted key', (tester) async {
      final controller = await pumpKeypad(tester, dpad: true);

      // The highlight starts on the first key of the first row, which is 'q'
      // on the English QWERTY layout.
      await send(tester, LogicalKeyboardKey.select);

      expect(controller.text, 'q');
    });

    testWidgets('arrow right moves along the row', (tester) async {
      final controller = await pumpKeypad(tester, dpad: true);

      await send(tester, LogicalKeyboardKey.arrowRight);
      await send(tester, LogicalKeyboardKey.arrowRight);
      await send(tester, LogicalKeyboardKey.enter);

      expect(controller.text, 'e');
    });

    testWidgets('arrow down lands on the closest key in the next row',
        (tester) async {
      final controller = await pumpKeypad(tester, dpad: true);

      // Row 0 starts 'qwerty', row 1 starts 'asdf'. Moving down from 'q'
      // should reach 'a', the nearest key horizontally.
      await send(tester, LogicalKeyboardKey.arrowDown);
      await send(tester, LogicalKeyboardKey.select);

      expect(controller.text, 'a');
    });

    testWidgets('highlight does not run past the end of a row', (tester) async {
      final controller = await pumpKeypad(tester, dpad: true);

      // Walking left from the first key is out of bounds and must not move or
      // crash; the keyboard leaves the event for the app to handle.
      await send(tester, LogicalKeyboardKey.arrowLeft);
      await send(tester, LogicalKeyboardKey.arrowLeft);
      await send(tester, LogicalKeyboardKey.select);

      expect(controller.text, 'q');
    });

    testWidgets('shift key reached by D-pad still toggles case',
        (tester) async {
      final controller = await pumpKeypad(tester, dpad: true);

      // Row 2 of QWERTY starts with shift.
      await send(tester, LogicalKeyboardKey.arrowDown);
      await send(tester, LogicalKeyboardKey.arrowDown);
      await send(tester, LogicalKeyboardKey.select);

      // Back up to the first row and type; shift should still be latched.
      await send(tester, LogicalKeyboardKey.arrowUp);
      await send(tester, LogicalKeyboardKey.arrowUp);
      await send(tester, LogicalKeyboardKey.select);

      expect(controller.text, 'Q');
    });

    testWidgets('does nothing when disabled', (tester) async {
      final controller = await pumpKeypad(tester, dpad: false);

      await send(tester, LogicalKeyboardKey.arrowRight);
      await send(tester, LogicalKeyboardKey.select);
      await send(tester, LogicalKeyboardKey.enter);

      expect(controller.text, isEmpty);
    });

    testWidgets('ignores the D-pad while the keyboard is hidden',
        (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(
                    enableDpadNavigation: true,
                    hideWhenUnfocused: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Nothing is focused, so the keyboard is collapsed. Swallowing arrow
      // keys or typing a character here would be invisible to the user.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(controller.text, isEmpty);
    });

    testWidgets('only one visible keyboard consumes a D-pad press',
        (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const Expanded(
                    child: VirtualKeypad(enableDpadNavigation: true),
                  ),
                  const Expanded(
                    child: VirtualKeypad(enableDpadNavigation: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // Every HardwareKeyboard handler runs for every event, so without an
      // owner both keyboards would insert the same character.
      expect(controller.text, 'q');
    });

    testWidgets('removes its key handler on dispose', (tester) async {
      final before = HardwareKeyboard.instance.physicalKeysPressed.length;
      await pumpKeypad(tester, dpad: true);

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // A leaked handler would throw once the state is gone.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(HardwareKeyboard.instance.physicalKeysPressed.length, before);
    });
  });
}
