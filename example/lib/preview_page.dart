// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:virtual_keypad/virtual_keypad.dart';

import 'demo_presets.dart';

/// Every layout, size, and theme side by side, so they can be compared without
/// changing settings one at a time.
///
/// The keyboards here are previews: they render but do not take input, because
/// nothing is focused behind them.
class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  void initState() {
    super.initState();
    // The active language lives on the provider, not on this page, so repaint
    // whenever it changes.
    KeyboardLayoutProvider.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    KeyboardLayoutProvider.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = KeyboardLayoutProvider.instance.currentLanguageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview gallery'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const _GroupHeader(
                icon: Icons.dialpad_rounded,
                title: 'Layouts',
                subtitle: 'What each KeyboardType renders',
              ),
              _LanguagePicker(
                current: current,
                onSelected: (code) =>
                    KeyboardLayoutProvider.instance.setLanguage(code),
              ),
              const SizedBox(height: 16),
              const _Preview(label: 'Text', type: KeyboardType.text),
              const _Preview(label: 'Number', type: KeyboardType.number),
              const _Preview(label: 'Phone', type: KeyboardType.phone),
              const _Preview(label: 'Email', type: KeyboardType.emailAddress),
              const _Preview(label: 'URL', type: KeyboardType.url),
              const _Preview(
                label: 'PIN pad (custom)',
                type: KeyboardType.custom,
              ),

              const _GroupHeader(
                icon: Icons.height_rounded,
                title: 'Heights',
                subtitle: 'The height parameter, same layout throughout',
              ),
              const _Preview(label: 'Compact, 200', height: 200),
              const _Preview(label: 'Default, 280', height: 280),
              const _Preview(label: 'Tall, 340', height: 340),

              const _GroupHeader(
                icon: Icons.palette_rounded,
                title: 'Themes',
                subtitle: 'Two built in, four built with VirtualKeypadTheme',
              ),
              const _ThemeGallery(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switches the language every preview on the page renders in.
///
/// Layouts differ far more by language than by type: QWERTY against AZERTY
/// against Bengali against Arabic, which is also right to left.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.current, required this.onSelected});

  final String current;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final language in allLanguages)
          ChoiceChip(
            label: Text(languageLabel(language.code)),
            selected: language.code == current,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: language.code == current
                  ? scheme.onPrimary
                  : scheme.onSurface,
            ),
            selectedColor: scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            onSelected: (_) => onSelected(language.code),
          ),
      ],
    );
  }
}

class _ThemeGallery extends StatelessWidget {
  const _ThemeGallery();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final preset in keypadPresets)
          _Preview(label: preset.name, theme: preset.theme),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.label,
    this.type = KeyboardType.text,
    this.height = 240,
    this.theme,
  });

  final String label;
  final KeyboardType type;
  final double height;
  final VirtualKeypadTheme? theme;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: scheme.outline,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              // Previews are for looking at, not typing into: nothing is
              // focused behind them, so taps would do nothing anyway.
              child: IgnorePointer(
                child: VirtualKeypad(
                  type: type,
                  customLayout: type == KeyboardType.custom ? pinLayout : null,
                  height: height,
                  theme: theme ?? VirtualKeypadTheme.light,
                  hideWhenUnfocused: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: scheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
