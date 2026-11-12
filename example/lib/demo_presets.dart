// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

/// Every language registered by `initializeKeyboardLayouts()`, plus any you
/// register yourself. Read from the provider rather than hardcoded, so this
/// list stays correct as languages are added.
List<KeyboardLanguage> get allLanguages =>
    KeyboardLayoutProvider.instance.languages.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

/// Label for a language chip, marking right-to-left scripts.
String languageLabel(String code) {
  final language = allLanguages.firstWhere((l) => l.code == code);
  return language.isRTL
      ? '${language.nativeName}  ·  RTL'
      : language.nativeName;
}

/// A 3x4 PIN pad, to show what `KeyboardType.custom` takes.
///
/// Shared so the playground and the preview gallery show the same thing.
final pinLayout = <KeyRow>[
  [
    VirtualKey.character(text: '1'),
    VirtualKey.character(text: '2'),
    VirtualKey.character(text: '3'),
  ],
  [
    VirtualKey.character(text: '4'),
    VirtualKey.character(text: '5'),
    VirtualKey.character(text: '6'),
  ],
  [
    VirtualKey.character(text: '7'),
    VirtualKey.character(text: '8'),
    VirtualKey.character(text: '9'),
  ],
  [
    VirtualKey.action(action: KeyAction.backSpace),
    VirtualKey.character(text: '0'),
    VirtualKey.action(action: KeyAction.done, label: 'OK'),
  ],
];

/// A named [VirtualKeypadTheme], so the demo can list presets in one place.
class KeypadPreset {
  const KeypadPreset(this.name, this.theme);

  final String name;
  final VirtualKeypadTheme theme;
}

/// The two built-in themes, plus four built with the same public API you would
/// use in your own app.
final keypadPresets = <KeypadPreset>[
  const KeypadPreset('Light', VirtualKeypadTheme.light),
  const KeypadPreset('Dark', VirtualKeypadTheme.dark),

  // Deep navy, rounder keys, no shadow. Reads well on a dark app.
  const KeypadPreset(
    'Midnight',
    VirtualKeypadTheme(
      backgroundColor: Color(0xFF0F172A),
      keyColor: Color(0xFF1E293B),
      actionKeyColor: Color(0xFF334155),
      keyTextColor: Color(0xFFE2E8F0),
      keyBorderRadius: 12,
      keyShadow: false,
      splashColor: Color(0x33FFFFFF),
    ),
  ),

  // Warm neutral, the sort of palette a reading or notes app uses.
  const KeypadPreset(
    'Sand',
    VirtualKeypadTheme(
      backgroundColor: Color(0xFFEFE7DA),
      keyColor: Color(0xFFFFFDF9),
      actionKeyColor: Color(0xFFDCCBB0),
      keyTextColor: Color(0xFF4A3F31),
      keyBorderRadius: 10,
    ),
  ),

  // Flat and high contrast: no shadow, tight corners.
  const KeypadPreset(
    'Mono',
    VirtualKeypadTheme(
      backgroundColor: Color(0xFFFFFFFF),
      keyColor: Color(0xFFF2F2F2),
      actionKeyColor: Color(0xFFDEDEDE),
      keyTextColor: Color(0xFF111111),
      keyBorderRadius: 4,
      keyShadow: false,
    ),
  ),

  // Large text and generous keys, for a kiosk or POS screen used at arm's
  // length. Also sets the D-pad highlight, which matters on TV.
  const KeypadPreset(
    'Kiosk',
    VirtualKeypadTheme(
      backgroundColor: Color(0xFF12343B),
      keyColor: Color(0xFF2D5F5D),
      actionKeyColor: Color(0xFF1B4B49),
      keyTextColor: Color(0xFFFFFFFF),
      keyTextSize: 26,
      keyBorderRadius: 14,
      horizontalGap: 8,
      verticalGap: 10,
      focusBorderColor: Color(0xFFFFC857),
      focusBorderWidth: 4,
    ),
  ),

  // A brand font on the keys. keyTextStyle is merged over keyTextColor and
  // keyTextSize, so this only has to name what it wants to change.
  const KeypadPreset(
    'Branded',
    VirtualKeypadTheme(
      backgroundColor: Color(0xFF1A1423),
      keyColor: Color(0xFF3D314A),
      actionKeyColor: Color(0xFF684756),
      keyTextColor: Color(0xFFF5F0F6),
      keyTextSize: 24,
      keyBorderRadius: 10,
      keyTextStyle: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
    ),
  ),
];
