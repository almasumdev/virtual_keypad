// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

TextStyle _styleOf(WidgetTester tester, String label) {
  final text = tester.widget<Text>(
    find.descendant(of: find.byType(VirtualKeypad), matching: find.text(label)),
  );
  return text.style!;
}

Future<void> _pump(WidgetTester tester, VirtualKeypadTheme theme) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualKeypad(
          type: KeyboardType.number,
          theme: theme,
          onKeyPressed: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('Key Text Style', () {
    testWidgets('a brand font reaches the key labels', (tester) async {
      await _pump(
        tester,
        const VirtualKeypadTheme(
          keyTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      );

      final style = _styleOf(tester, '1');
      expect(style.fontFamily, 'Inter');
      expect(style.fontWeight, FontWeight.w600);
      expect(style.letterSpacing, 1.5);
    });

    testWidgets('size and color still come from the theme when unset', (
      tester,
    ) async {
      await _pump(
        tester,
        const VirtualKeypadTheme(
          keyTextSize: 31.0,
          keyTextColor: Color(0xFF00FF00),
          keyTextStyle: TextStyle(fontFamily: 'Inter'),
        ),
      );

      final style = _styleOf(tester, '1');
      expect(style.fontSize, 31.0);
      expect(style.color, const Color(0xFF00FF00));
      expect(style.fontFamily, 'Inter');
    });

    testWidgets('an explicit size and color in the style win', (tester) async {
      await _pump(
        tester,
        const VirtualKeypadTheme(
          keyTextSize: 31.0,
          keyTextColor: Color(0xFF00FF00),
          keyTextStyle: TextStyle(fontSize: 12.0, color: Color(0xFFFF0000)),
        ),
      );

      final style = _styleOf(tester, '1');
      expect(style.fontSize, 12.0);
      expect(style.color, const Color(0xFFFF0000));
    });

    testWidgets('themes without the new field are unchanged', (tester) async {
      await _pump(tester, const VirtualKeypadTheme(keyTextSize: 19.0));

      final style = _styleOf(tester, '1');
      expect(style.fontSize, 19.0);
      expect(style.fontFamily, isNull);
    });

    test('copyWith carries the style through', () {
      const style = TextStyle(fontFamily: 'Inter');
      const base = VirtualKeypadTheme();
      expect(base.copyWith(keyTextStyle: style).keyTextStyle, style);
      expect(base.copyWith(keyTextStyle: style).copyWith().keyTextStyle, style);
    });
  });
}
