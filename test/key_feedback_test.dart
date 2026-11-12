// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Records the platform calls that haptics and system sounds travel on.
///
/// Both go out over `SystemChannels.platform` as `HapticFeedback.vibrate` and
/// `SystemSound.play`, so watching that one channel covers every combination.
class _PlatformCallLog {
  final calls = <MethodCall>[];

  List<String> get haptics => calls
      .where((c) => c.method == 'HapticFeedback.vibrate')
      .map((c) => c.arguments as String)
      .toList();

  int get soundCount =>
      calls.where((c) => c.method == 'SystemSound.play').length;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
  }

  void remove() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _PlatformCallLog log;

  setUp(() {
    log = _PlatformCallLog();
    log.install();
  });

  tearDown(() => log.remove());

  /// Mounts a standalone keypad over a text field and taps the `a` key.
  Future<void> pressAKey(WidgetTester tester, KeyFeedback feedback) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VirtualKeypadScope(
            child: Column(
              children: [
                VirtualKeypadTextField(controller: VirtualKeypadController()),
                VirtualKeypad(feedback: feedback),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    log.calls.clear();

    await tester.tap(find.text('a').first);
    await tester.pumpAndSettle();
  }

  group('Key Feedback', () {
    testWidgets('goes fully silent and still when asked for none',
        (tester) async {
      await pressAKey(tester, KeyFeedback.none);

      expect(log.haptics, isEmpty);
      expect(log.soundCount, 0);
    });

    testWidgets('clicks by default, matching the ink response it replaces',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: VirtualKeypadController()),
                  const VirtualKeypad(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      log.calls.clear();

      await tester.tap(find.text('a').first);
      await tester.pumpAndSettle();

      expect(log.soundCount, 1);
      expect(log.haptics, isEmpty);
    });

    testWidgets('plays the click exactly once, not twice', (tester) async {
      await pressAKey(tester, KeyFeedback.sound);

      // Material's ink response is switched off, so the only source is the
      // key handler. Without that, a tap would click twice.
      expect(log.soundCount, 1);
    });

    testWidgets('vibrates without clicking when asked for haptics only',
        (tester) async {
      await pressAKey(tester, KeyFeedback.haptic);

      expect(log.haptics, ['HapticFeedbackType.lightImpact']);
      expect(log.soundCount, 0);
    });

    testWidgets('plays the click sound without vibrating', (tester) async {
      await pressAKey(tester, KeyFeedback.sound);

      expect(log.haptics, isEmpty);
      expect(log.soundCount, 1);
    });

    testWidgets('does both when asked for both', (tester) async {
      await pressAKey(tester, KeyFeedback.both);

      expect(log.haptics, ['HapticFeedbackType.lightImpact']);
      expect(log.soundCount, 1);
    });

    testWidgets('fires once per press rather than once per rebuild',
        (tester) async {
      await pressAKey(tester, KeyFeedback.haptic);
      await tester.tap(find.text('b').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('c').first);
      await tester.pumpAndSettle();

      expect(log.haptics.length, 3);
    });

    testWidgets('confirms an action key, not only a character', (tester) async {
      await pressAKey(tester, KeyFeedback.haptic);
      log.calls.clear();

      await tester.tap(find.byIcon(Icons.backspace_outlined).first);
      await tester.pumpAndSettle();

      expect(log.haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('leaves the typed text untouched', (tester) async {
      final controller = VirtualKeypadController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeypadScope(
              child: Column(
                children: [
                  VirtualKeypadTextField(controller: controller),
                  const VirtualKeypad(feedback: KeyFeedback.both),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('a').first);
      await tester.pumpAndSettle();

      expect(controller.text, 'a');
    });
  });

  group('Floating Key Feedback', () {
    /// Mounts the floating host with a one-key layout and presses that key.
    ///
    /// A full layout overflows the test viewport and leaves keys unhittable,
    /// so the panel is sized the way the other floating tests size it.
    Future<void> pressInFloating(WidgetTester tester,
        {KeyFeedback? feedback}) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: VirtualKeypadFloating(
                standalone: true,
                width: 280,
                feedback: feedback ?? KeyFeedback.sound,
                type: KeyboardType.custom,
                customLayout: [
                  [VirtualKey.character(text: '1')],
                ],
                child: Column(children: [TextField(controller: controller)]),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      log.calls.clear();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
    }

    testWidgets('forwards the setting into the floating panel', (tester) async {
      await pressInFloating(tester, feedback: KeyFeedback.haptic);

      expect(log.haptics, ['HapticFeedbackType.lightImpact']);
      expect(log.soundCount, 0);
    });

    testWidgets('clicks by default, like the docked keypad', (tester) async {
      await pressInFloating(tester);

      expect(log.soundCount, 1);
      expect(log.haptics, isEmpty);
    });

    testWidgets('goes silent when asked for none', (tester) async {
      await pressInFloating(tester, feedback: KeyFeedback.none);

      expect(log.haptics, isEmpty);
      expect(log.soundCount, 0);
    });
  });
}
