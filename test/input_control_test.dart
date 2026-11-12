// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Records the input type the framework hands the platform for each field.
///
/// A custom [TextInputControl] does not stop `TextInput.show` reaching the
/// platform channel: the platform control stays subscribed and still forwards
/// it. What actually suppresses the OS keyboard is the configuration, which
/// Flutter rewrites to `TextInputType.none` while a custom control is
/// installed. So the honest observable is the input type on `setClient` and
/// `updateConfig`, not the show call.
class _InputTypeSpy {
  final List<String> types = <String>[];

  void install(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.textInput,
      (call) async {
        if (call.method == 'TextInput.setClient') {
          final args = call.arguments as List<dynamic>;
          types.add(_typeOf(args[1] as Map<dynamic, dynamic>));
        } else if (call.method == 'TextInput.updateConfig') {
          types.add(_typeOf(call.arguments as Map<dynamic, dynamic>));
        }
        return null;
      },
    );
  }

  static String _typeOf(Map<dynamic, dynamic> config) {
    final inputType = config['inputType'] as Map<dynamic, dynamic>?;
    return (inputType?['name'] as String?) ?? 'unknown';
  }

  void remove(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.textInput,
      null,
    );
  }

  /// Whether the platform was last told this field takes no input, which is
  /// how the OS keyboard is kept down.
  bool get suppressed => types.isNotEmpty && types.last == 'TextInputType.none';

  void clear() => types.clear();
}

void main() {
  late _InputTypeSpy spy;

  setUp(() => spy = _InputTypeSpy());

  Widget app({required Widget body}) => MaterialApp(home: Scaffold(body: body));

  testWidgets('a standalone keypad suppresses the system keyboard while alive',
      (
    tester,
  ) async {
    spy.install(tester);
    addTearDown(() => spy.remove(tester));

    await tester.pumpWidget(
      app(
        body: const Column(
          children: [TextField(), VirtualKeypad(standalone: true)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    spy.clear();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(
      spy.suppressed,
      isTrue,
      reason: 'suppressing the OS keyboard is the point of standalone mode',
    );
  });

  testWidgets(
    'the system keyboard works again after a standalone keypad is disposed',
    (tester) async {
      spy.install(tester);
      addTearDown(() => spy.remove(tester));

      await tester.pumpWidget(
        app(
          body: const Column(
            children: [TextField(), VirtualKeypad(standalone: true)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Replace the whole tree, disposing the keypad.
      await tester.pumpWidget(app(body: const TextField()));
      await tester.pumpAndSettle();

      spy.clear();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(
        spy.suppressed,
        isFalse,
        reason:
            'the keypad must hand the platform input control back on dispose, '
            'or every later text field is left with no keyboard',
      );
    },
  );
}
