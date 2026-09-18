<p align="center">
  <a href="https://pub.dev/packages/virtual_keypad"><img src="https://img.shields.io/pub/v/virtual_keypad.svg" alt="pub version"></a>
  <a href="https://pub.dev/packages/virtual_keypad/score"><img src="https://img.shields.io/pub/points/virtual_keypad" alt="pub points"></a>
  <a href="https://pub.dev/packages/virtual_keypad"><img src="https://img.shields.io/pub/likes/virtual_keypad" alt="pub likes"></a>
  <a href="https://github.com/almasumdev/virtual_keypad/stargazers"><img src="https://badgen.net/github/stars/almasumdev/virtual_keypad?icon=github" alt="GitHub stars"></a>
  <a href="https://github.com/almasumdev/virtual_keypad/network/members"><img src="https://badgen.net/github/forks/almasumdev/virtual_keypad?icon=github" alt="GitHub forks"></a>
  <a href="https://github.com/almasumdev/virtual_keypad/issues"><img src="https://badgen.net/github/open-issues/almasumdev/virtual_keypad?icon=github" alt="GitHub issues"></a>
  <a href="https://github.com/almasumdev/virtual_keypad/actions/workflows/ci.yml"><img src="https://github.com/almasumdev/virtual_keypad/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
  <a href="https://github.com/almasumdev/virtual_keypad/commits/main"><img src="https://badgen.net/github/last-commit/almasumdev/virtual_keypad?icon=github" alt="Last commit"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter"></a>
</p>

# Virtual Keyboard and On-Screen Keypad for Flutter

**virtual_keypad** is an on-screen keyboard widget for Flutter: a software
keyboard you draw inside your own app instead of relying on the system keyboard.
It gives you a full QWERTY virtual keyboard, a numeric keypad or numpad, a phone
dialer, and custom PIN pad or OTP layouts, on Android, iOS, Web, Windows, macOS,
and Linux.

Use it where the platform soft keyboard is missing, blocked, or not enough:
kiosk and self-service terminals, ATM and point of sale (POS) screens,
touchscreen and desktop apps, Android TV and set-top boxes driven by a D-pad
remote, embedded displays, and secure PIN entry where you would rather the
system keyboard stayed out of it. It drops into any standard `TextField` or
`TextFormField` with one line, and it ships 14 languages including
right-to-left Arabic.

> 📘 **[Documentation](https://virtual-keypad-docs.web.app)**: guides for
> [using any TextField](https://virtual-keypad-docs.web.app/standalone-mode),
> [numeric and PIN pads](https://virtual-keypad-docs.web.app/numeric-keypad-pin),
> [the floating panel](https://virtual-keypad-docs.web.app/floating-keyboard),
> [kiosk and POS](https://virtual-keypad-docs.web.app/kiosk-and-pos),
> [Android TV and D-pad](https://virtual-keypad-docs.web.app/android-tv),
> [custom layouts](https://virtual-keypad-docs.web.app/custom-layouts),
> [theming](https://virtual-keypad-docs.web.app/theming),
> [languages and RTL](https://virtual-keypad-docs.web.app/languages-and-rtl),
> [emoji](https://virtual-keypad-docs.web.app/emoji-keyboard) and
> [troubleshooting](https://virtual-keypad-docs.web.app/troubleshooting).

> ⭐ **Find this useful?** [Star it on GitHub](https://github.com/almasumdev/virtual_keypad)
> and 👍 [like it on pub.dev](https://pub.dev/packages/virtual_keypad). Stars and likes
> help other Flutter developers find a maintained on-screen keyboard package.

## Overview

virtual_keypad renders the keyboard as a customizable Flutter widget, so it
lives inside your widget tree, follows your theme, and works the same on every
platform. There is no native code and no platform channel involved.

**What you can do with it:**

- Add a virtual keyboard to any existing `TextField` or `TextFormField` by passing `standalone: true`, with no other changes to your form.
- Build a numeric keypad, PIN pad, or OTP entry screen from your own key layout.
- Float the keyboard in a draggable panel for desktop, kiosk, and split-view screens.
- Switch between 14 built-in languages at runtime, or register your own layout.
- Block the system keyboard entirely when you need full control over input.

<p align="center">
  <img src="https://raw.githubusercontent.com/almasumdev/virtual_keypad/main/previews/showcase-devices.png"
       alt="Six virtual_keypad on-screen keyboards side by side: a wide desktop email layout, the color emoji page, a dark custom PIN pad, phone QWERTY, Arabic right to left, and a themed numeric kiosk keypad" width="100%"/>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/almasumdev/virtual_keypad/main/previews/showcase-languages.png"
       alt="Six of the fourteen built-in multilingual keyboard layouts: Bengali, Hindi Devanagari, Russian JCUKEN Cyrillic, Korean Dubeolsik Hangul, Thai Kedmanee, and French AZERTY" width="100%"/>
</p>

<p align="center">
  <sub>Every keyboard above is the same VirtualKeypad widget with different
  arguments, captured at scale against each other.</sub>
</p>

## Table of contents

- [Virtual Keyboard and On-Screen Keypad for Flutter](#virtual-keyboard-and-on-screen-keypad-for-flutter)
  - [Overview](#overview)
  - [Table of contents](#table-of-contents)
  - [Key features](#key-features)
  - [Which mode should you use?](#which-mode-should-you-use)
  - [Limitations](#limitations)
  - [Roadmap](#roadmap)
  - [Example](#example)
  - [Other useful links](#other-useful-links)
  - [Installation](#installation)
  - [Getting started](#getting-started)
    - [Standalone mode: any TextField](#standalone-mode-any-textfield)
    - [Submit actions in standalone mode](#submit-actions-in-standalone-mode)
    - [Scoped standalone mode](#scoped-standalone-mode)
    - [Floating mode: a draggable keyboard panel](#floating-mode-a-draggable-keyboard-panel)
    - [Keeping a floating keypad on screen](#keeping-a-floating-keypad-on-screen)
    - [Scope mode: full control](#scope-mode-full-control)
    - [Keyboard types](#keyboard-types)
    - [Build a PIN pad or numeric keypad](#build-a-pin-pad-or-numeric-keypad)
    - [Emoji support](#emoji-support)
    - [Android TV and remote control](#android-tv-and-remote-control)
    - [Key press feedback](#key-press-feedback)
  - [Theming and customization](#theming-and-customization)
    - [Multi-language and RTL](#multi-language-and-rtl)
    - [Add your own language](#add-your-own-language)
    - [Drive the keyboard from code](#drive-the-keyboard-from-code)
    - [Focused imports](#focused-imports)
  - [Supported languages](#supported-languages)
  - [Common setup mistakes](#common-setup-mistakes)
  - [FAQ](#faq)
  - [Support and feedback](#support-and-feedback)
  - [About](#about)
    - [Contributors](#contributors)

## Key features

Expand a group for the full list:

<details>
<summary><b>🎹 Layouts &amp; keyboard types</b></summary>

- QWERTY text, multiline, email, URL, password, name, and street address layouts
- Numeric keypad and numpad, signed and decimal variants
- Phone dialer layout
- Fully custom layouts for PIN pads, OTP entry, checkout, ATM, and POS screens
- Layout adapts automatically to the focused field's `keyboardType`
- Symbols and secondary or tertiary pages per language

</details>

<details>
<summary><b>🔌 Integration modes</b></summary>

- Standalone: works with any stock `TextField` or `TextFormField`
- Scoped standalone: limits the keyboard to one widget subtree
- Floating: a draggable, dockable overlay panel
- Scope: full focus routing, submit handling, and system keyboard blocking
- Input action callbacks for `done`, `search`, `send`, `call`, and `next`

</details>

<details>
<summary><b>🌍 Languages &amp; scripts</b></summary>

- 14 built-in languages registered by one call to `initializeKeyboardLayouts()`
- Latin QWERTY, QWERTZ, and AZERTY layouts
- Cyrillic (ЙЦУКЕН), Arabic, Bengali, Devanagari, Hangul, and Thai scripts
- Right-to-left (RTL) input for Arabic
- Long-press the space bar to switch language
- Register your own `KeyboardLanguage` at runtime

</details>

<details>
<summary><b>🎨 Theming &amp; appearance</b></summary>

- Built-in light and dark themes
- Fully customizable theme: background, key, and action key colors
- Key text color, size, corner radius, shadow, and splash color
- `copyWith` to tweak a built-in theme
- Native-style key press preview popup

</details>

<details>
<summary><b>✂️ Editing &amp; input control</b></summary>

- Insert, backspace, select all, and clear from code
- Cursor positioning and left/right movement
- Text selection and copy/paste keys
- Optional system keyboard blocking with `allowPhysicalKeyboard: false`
- Character limits via `maxLength`, single or multi-line via `maxLines`
- Animated show and hide on focus change

</details>

<details>
<summary><b>📺 TV &amp; remote control</b></summary>

- D-pad and remote navigation with `enableDpadNavigation: true`
- Arrow keys move the highlight, select or enter presses the key
- Up and down land on the nearest key horizontally, so space and shift stay reachable
- Themeable highlight: border color, width, and background
- Works on Android TV, Fire TV, and set-top boxes with no touch screen
- The focused text field keeps focus, so the keyboard never hides mid-navigation

</details>

<details>
<summary><b>📱 Platforms &amp; footprint</b></summary>

- Android, iOS, Web, Windows, macOS, and Linux
- Pure Dart and Flutter widgets, no native code or platform channels
- One dependency, `emoji_picker_flutter`, used only for the emoji page
- Emoji render offline on web from a bundled 708 KB font, with optional runtime color
- Four focused import points so you pull in only what you use

</details>

## Which mode should you use?

| Mode | Best for | Widgets |
|---|---|---|
| **Standalone** | Dropping a keyboard into an existing form with the least work | `TextField` + `VirtualKeypad(standalone: true)` |
| **Scoped standalone** | Limiting the keyboard to one panel, page, or Widgetbook story | `VirtualKeypadStandaloneScope` |
| **Floating** | Draggable overlay keyboards on desktop, kiosk, and POS screens | `VirtualKeypadFloating` |
| **Scope** | Submit handling, focus-driven layouts, and blocking the system keyboard | `VirtualKeypadScope` + `VirtualKeypadTextField` + `VirtualKeypad` |

Standalone mode is the right default. Move to scope mode when you need
predictable focus routing, custom submit behavior, or secure input.

## Limitations

- ❌ No word prediction, autocorrect, or swipe typing
- ❌ No handwriting or voice input

## Roadmap

What ships next is driven by user requests on the
[issue tracker](https://github.com/almasumdev/virtual_keypad/issues):

- ⬜ More built-in languages and layouts (contributions welcome)

Shipped milestones are in the
[changelog](https://github.com/almasumdev/virtual_keypad/blob/main/CHANGELOG.md).

## Example

<p align="center">
  <a href="https://masum-vk.web.app">
    <img src="https://img.shields.io/badge/▶%20Live%20Demo-masum--vk.web.app-FF6F00?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Open the live demo">
  </a>
</p>

> **[▶ Try the live demo](https://masum-vk.web.app)**: type on the keyboard,
> switch languages, and try the floating panel in your browser. Nothing to install.

A complete, runnable app lives in the
[`example/`](https://github.com/almasumdev/virtual_keypad/tree/main/example)
directory: one page, one file, where every option is a switch or a chip. Change
keyboard type, language, theme, emoji, floating mode, and D-pad navigation and
watch the same keyboard react. Clone the repository and run it, or copy any
snippet from [Getting started](#getting-started) below.

## Other useful links

- [Documentation and guides](https://virtual-keypad-docs.web.app)
- [API reference](https://pub.dev/documentation/virtual_keypad/latest/)
- [Source code on GitHub](https://github.com/almasumdev/virtual_keypad)
- [Changelog](https://github.com/almasumdev/virtual_keypad/blob/main/CHANGELOG.md)
- [Issue tracker](https://github.com/almasumdev/virtual_keypad/issues)
- [Contributing](https://github.com/almasumdev/virtual_keypad/blob/main/CONTRIBUTING.md)
- [Floating mode guide](https://github.com/almasumdev/virtual_keypad/blob/main/doc/floating-mode.md)
- [Custom layouts guide](https://github.com/almasumdev/virtual_keypad/blob/main/doc/custom-layouts.md)
- [Adding languages guide](https://github.com/almasumdev/virtual_keypad/blob/main/doc/adding-languages.md)
- [Theming guide](https://github.com/almasumdev/virtual_keypad/blob/main/doc/theming.md)

## Installation

```bash
flutter pub add virtual_keypad
```

Then import it:

```dart
import 'package:virtual_keypad/virtual_keypad.dart';
```

Call `initializeKeyboardLayouts()` once before `runApp()`. That registers all 12
built-in languages:

```dart
void main() {
  initializeKeyboardLayouts();
  runApp(const MyApp());
}
```

## Getting started

### Standalone mode: any TextField

Add `standalone: true` and the keyboard finds the focused field on its own. No
wrapper widgets, no controller swap, no changes to your existing form:

```dart
class LoginForm extends StatelessWidget {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: controller),
        VirtualKeypad(standalone: true),
      ],
    );
  }
}
```

The keyboard reads each field's `keyboardType` and switches layout to match, so
an email field gets `@` and `.`, and a number field gets a numeric keypad.

### Submit actions in standalone mode

Use `onStandaloneInputAction` to tell submit-style keys apart at the keyboard
level, which is how you wire up a dialer or a search bar:

```dart
VirtualKeypad(
  standalone: true,
  type: KeyboardType.custom,
  customLayout: [
    [VirtualKey.action(action: KeyAction.call)],
  ],
  onStandaloneInputAction: (action, text) {
    if (action == KeyAction.call) {
      placeCall(text);
    }
  },
)
```

### Scoped standalone mode

Wrap a subtree in `VirtualKeypadStandaloneScope` and only fields inside it will
trigger that keyboard. This keeps multi-panel layouts and Widgetbook stories
from fighting over focus:

```dart
VirtualKeypadStandaloneScope(
  child: Column(
    children: [
      TextField(controller: controller),
      VirtualKeypad(standalone: true),
    ],
  ),
)
```

### Floating mode: a draggable keyboard panel

`VirtualKeypadFloating` gives you the same keyboard in a movable panel that sits
above your UI instead of taking a slice of the layout:

```dart
VirtualKeypadFloating(
  standalone: true,
  enableEmojiKey: true,
  width: 360,
  height: 280,
  borderRadius: 20,
  theme: VirtualKeypadTheme.dark,
  child: Column(
    children: [
      TextField(controller: controller),
    ],
  ),
)
```

Floating mode is additive. Existing `VirtualKeypad()` and
`VirtualKeypad(standalone: true)` code keeps working unchanged.

### Keeping a floating keypad on screen

For kiosk and POS screens where the keyboard should always be available, pair it
with a controller and use persistent visibility:

```dart
final floatingController = VirtualKeypadFloatingController();

VirtualKeypadFloating(
  controller: floatingController,
  visibilityMode: VirtualKeypadFloatingVisibilityMode.persistent,
  width: 420,
  borderRadius: 20,
  child: Column(
    children: [
      TextField(controller: controller),
    ],
  ),
)
```

The panel then stays up until you call `floatingController.hide()` or the user
closes it from the toolbar. `dockTop()` and `dockBottom()` snap it into place.

### Scope mode: full control

Three widgets work together here: `VirtualKeypadScope` wraps the subtree,
`VirtualKeypadTextField` replaces your text fields, and `VirtualKeypad` renders
the keys. Use it when you want selection callbacks, submit handling, and the
system keyboard blocked:

```dart
class _MyFormState extends State<MyForm> {
  final controller = VirtualKeypadController();

  @override
  Widget build(BuildContext context) {
    return VirtualKeypadScope(
      child: Column(
        children: [
          VirtualKeypadTextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Enter text'),
          ),
          VirtualKeypad(),
        ],
      ),
    );
  }
}
```

`VirtualKeypadTextField` blocks physical and system keyboard input by default.
Pass `allowPhysicalKeyboard: true` if you want both.

### Keyboard types

```dart
VirtualKeypadTextField(
  controller: controller,
  keyboardType: KeyboardType.emailAddress, // shows @ and .
)
```

| Type | Use case |
|---|---|
| `text` | General text input (QWERTY) |
| `emailAddress` | Email fields, with `@` and `.` on the main page |
| `url` | URL fields, with `/`, `:`, and `.` on the main page |
| `number` | Numeric keypad and numpad input |
| `phone` | Phone dialer |
| `multiline` | Text areas with a newline key |
| `custom` | Your own layout |

### Build a PIN pad or numeric keypad

Custom layouts are how you build a PIN pad, OTP entry, or any branded on-screen
keypad. Checkout, ATM, and POS flows all use the same mechanism:

```dart
final pinLayout = [
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
    VirtualKey.action(action: KeyAction.done, label: '✓'),
  ],
];

VirtualKeypad(
  type: KeyboardType.custom,
  customLayout: pinLayout,
)
```

`customLayout` and `type: KeyboardType.custom` must be used together. Invalid
combinations assert immediately in debug mode so setup mistakes fail fast.

### Emoji support

```dart
VirtualKeypad(
  standalone: true,
  enableEmojiKey: true,
)
```

That adds an emoji toggle to the text, multiline, email, URL, password, name,
and street address layouts. For an emoji-first surface such as a reaction picker
or an always-visible dock, open straight onto the emoji page:

```dart
VirtualKeypad(
  hideWhenUnfocused: false,
  enableEmojiKey: true,
  showEmojiKeyboardInitially: true,
)
```

`VirtualKeypadFloating` takes `enableEmojiKey` too.

**Emoji work offline, including on the web, with no setup.** Emoji glyphs
normally come from the platform. That is fine on Android, iOS, Windows, macOS,
and Linux, which all ship a system emoji font. Flutter web is different: the
CanvasKit and Skwasm renderers ignore the browser font stack and download a Noto
fallback font on demand, so a first load without a network connection would
paint every emoji as a blank box.

To close that gap this package bundles Noto Emoji, subset to the 1271 codepoints
the picker uses (708 KB). It is applied **only on web**, so native platforms keep
their own color emoji font untouched and pay nothing at render time. The bundled
font is monochrome, which is the trade for rendering reliably offline.

**Want color on web?** The bundled font is monochrome to keep the package small.
Subset to the same codepoints, Noto Color Emoji in COLRv1 form is about 3.9 MB
against 708 KB, because COLRv1 draws each emoji from many single-color layer
glyphs. Putting that in every app, including the mobile ones that already get
color emoji from the system font, is a poor trade.

Load it at runtime instead and you pay nothing in your bundle:

```dart
VirtualKeypad(
  standalone: true,
  enableEmojiKey: true,
  colorEmojiFontLoader: () async {
    final response = await http.get(Uri.parse(myColorEmojiFontUrl));
    return ByteData.sublistView(response.bodyBytes);
  },
)
```

The keyboard paints the bundled monochrome font immediately, then swaps to color
when the font arrives. If the fetch fails, because the device is offline or the
request was blocked, the monochrome font stays and emoji still render.

The package performs no fetch of its own, so nothing leaves the device unless you
write it. Self-host the font rather than hot-linking someone else's CDN, and
remember that kiosk, ATM, and enterprise deployments often disallow outbound
requests, which is why this is opt in.

You can also override the font outright with `emojiTextStyle`, or reuse the
bundled family elsewhere in your app:

```dart
// Use your own font on the emoji page.
VirtualKeypad(
  standalone: true,
  enableEmojiKey: true,
  emojiTextStyle: const TextStyle(fontFamily: 'NotoColorEmoji'),
)

// The bundled family, exported as a constant.
const TextStyle(fontFamily: kBundledEmojiFontFamily)
```

Inserted emoji are covered too. `VirtualKeypadTextField` appends the bundled
font as a fallback on web automatically, so scope mode needs nothing from you.

Standalone mode drives your own `TextField`, which the package cannot restyle
from the outside. One line on your theme closes that gap:

```dart
MaterialApp(
  theme: ThemeData.light().withVirtualKeypadEmojiFont(),
)
```

Both are no-ops off the web, so your platform color emoji font is never
overridden on Android, iOS, or desktop.

On Android you can also set `checkEmojiPlatformCompatibility: true` to drop
emoji the device's system font cannot render. That check is Android only and
adds work the first time the emoji page opens, so it is off by default.

### Android TV and remote control

Set `enableDpadNavigation: true` and the keyboard becomes usable with nothing but
a directional pad, which is what Android TV, Fire TV, and set-top boxes give you:

```dart
VirtualKeypad(
  standalone: true,
  enableDpadNavigation: true,
  theme: VirtualKeypadTheme.dark.copyWith(
    focusBorderColor: Colors.amber,
    focusBorderWidth: 4,
  ),
)
```

One key is highlighted at a time. Arrow keys move the highlight, and select,
enter, or the primary gamepad button presses it. Moving up or down picks the key
in the next row that sits closest horizontally, so wide keys such as space and
shift stay reachable instead of being skipped.

Space is deliberately not treated as a press, so pairing a Bluetooth keyboard to
a TV still types a space rather than firing the highlighted key. At the edge of
the grid the arrow key is left unhandled, which lets your app move focus off the
keyboard instead of trapping the user inside it.

The highlight is drawn by the keyboard rather than by Flutter's focus system, so
the text field keeps focus and the keyboard does not hide while the user moves
around. Style it with `focusBorderColor`, `focusBorderWidth`, and `focusColor`.

The emoji page follows the same rules. With `enableDpadNavigation` on it swaps
its touch grid for one the remote can drive: a row of category icons across the
top, the emoji below, arrow keys to move and select to insert. Moving up from
the top row goes back to the categories, and up again closes the page and
returns to the letters, so the user is never stranded somewhere the remote
cannot leave. The grid stays tappable, so a device with both a touchscreen and
a remote behaves the same way either side. Without `enableDpadNavigation` the
usual touch picker is shown, unchanged.

### Key press feedback

A touchscreen gives no tactile confirmation on its own. On a kiosk or a POS
terminal the key preview is often the only sign that a tap registered at all:

```dart
VirtualKeypad(feedback: KeyFeedback.both)   // click and a light vibration
VirtualKeypad(feedback: KeyFeedback.none)   // silent and still
```

| Value | Does |
|---|---|
| `sound` | The platform key click. The default |
| `haptic` | A light vibration, no sound |
| `both` | Both |
| `none` | Neither |

`sound` is what the keyboard already did, through Material's ink response, so
the default sounds the same as before. The difference is that feedback now
comes from the single place every key press goes through, which means a D-pad
activation on a television is confirmed the same way a tap is. The ink response
only ever saw taps.

Both effects are handled by the platform, so there is no asset to bundle. A
device with no vibration motor or no key click skips that effect rather than
failing, and both follow the user's own settings including silent mode.

### Theming and customization

```dart
// Built-in themes.
VirtualKeypad(theme: VirtualKeypadTheme.light)
VirtualKeypad(theme: VirtualKeypadTheme.dark)

// A custom theme.
VirtualKeypad(
  theme: VirtualKeypadTheme(
    backgroundColor: Colors.grey[900]!,
    keyColor: Colors.grey[800]!,
    actionKeyColor: Colors.grey[700]!,
    keyTextColor: Colors.white,
    keyBorderRadius: 12,
  ),
)

// Tweak a built-in theme.
VirtualKeypad(
  theme: VirtualKeypadTheme.dark.copyWith(
    keyBorderRadius: 12,
    keyTextSize: 24,
  ),
)

// Put your brand font on the keys. Anything you leave out keeps the
// themed value, so this still uses keyTextSize and keyTextColor.
VirtualKeypad(
  theme: VirtualKeypadTheme.light.copyWith(
    keyTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

| Property | Type | Default | Description |
|---|---|---|---|
| `backgroundColor` | `Color` | `#D1D3D9` | Keyboard background |
| `keyColor` | `Color` | `#FFFFFF` | Character key background |
| `actionKeyColor` | `Color` | `#ADB3BC` | Action key background |
| `keyTextColor` | `Color` | `#1C1C1E` | Text and icon color |
| `keyTextSize` | `double` | `22.0` | Font size |
| `keyTextStyle` | `TextStyle?` | `null` | Key label style, merged over the color and size |
| `keyBorderRadius` | `double` | `6.0` | Corner radius |
| `keyShadow` | `bool` | `true` | Show key shadows |
| `splashColor` | `Color?` | `null` | Tap ripple color |
| `focusBorderColor` | `Color?` | `keyTextColor` | D-pad highlight border |
| `focusBorderWidth` | `double` | `3.0` | D-pad highlight border width |
| `focusColor` | `Color?` | `null` | D-pad highlight background |

### Draw a key yourself

`keyBuilder` replaces the content of a key. Return `null` for the keys you do
not want to change, so you can restyle one key and leave the rest alone:

```dart
VirtualKeypad(
  keyBuilder: (context, info) => info.key.action == KeyAction.enter
      ? const Text('GO', style: TextStyle(fontWeight: FontWeight.bold))
      : null,
)
```

`info` carries the key, its resolved `label` (null for keys drawn as an icon),
the current `shift` and `capsLock`, whether the key is D-pad `isFocused`, and
the `theme` in force.

This controls content only. The key's background, size, tap handling, repeat,
D-pad focus and accessibility stay with the package, so a builder cannot break
the keyboard's behaviour.

### Scramble the digits for PIN entry

A fixed keypad leaks the PIN to anyone watching the hand, or to a camera above
the terminal, because finger positions are enough on their own:

```dart
VirtualKeypad(
  type: KeyboardType.number,
  keyShuffle: KeyShuffle.onShow,     // reshuffle each time it appears
)
```

`KeyShuffle.onShow` is what payment terminals do: positions hold still while
someone is typing, so entry stays usable, but nothing carries from one entry to
the next. `KeyShuffle.onEveryKey` reshuffles after every press for maximum
resistance, at a real cost to usability. Default is `KeyShuffle.none`.

After a failed attempt the keypad is already on screen, which is exactly when a
watcher has learned the most, so `shuffleTrigger` forces a fresh arrangement:

```dart
final reshuffle = ChangeNotifier();
VirtualKeypad(keyShuffle: KeyShuffle.onShow, shuffleTrigger: reshuffle);
// on a wrong PIN:
reshuffle.notifyListeners();
```

Only single digits move. Backspace, the decimal point and every other key stay
put, and the full set of digits is always on screen. `shuffleDigitKeys` is
exported from `package:virtual_keypad/layouts.dart` if you want to apply the
same permutation to a custom layout yourself.

### Multi-language and RTL

```dart
initializeKeyboardLayouts(); // registers all 14 languages

KeyboardLayoutProvider.instance.setLanguage('ar'); // Arabic, RTL
KeyboardLayoutProvider.instance.setLanguage('ko'); // Korean
KeyboardLayoutProvider.instance.setLanguage('en'); // English

VirtualKeypad(
  availableLanguages: ['en', 'bn', 'ar'],
  initialLanguage: 'en',
  onLanguageChanged: (code) {
    // Save the code if you want to restore it on next launch.
  },
)
```

When `availableLanguages` holds more than one entry, users can long-press the
space bar to open the language picker. The first entry is the fallback for that
keyboard.

The selection lasts for the app session. To restore it after a restart, save the
code from `onLanguageChanged` and pass it back as `initialLanguage`.

### Add your own language

```dart
final myLanguage = KeyboardLanguage(
  code: 'xx',
  name: 'MyLanguage',
  nativeName: 'MyLanguage',
  textLayouts: KeyboardLayoutSet(
    primary: textPrimaryLayout,
    secondary: symbolsLayout,
    tertiary: moreSymbolsLayout,
  ),
);

KeyboardLayoutProvider.instance.registerLanguage(myLanguage);
KeyboardLayoutProvider.instance.setLanguage('xx');
```

### Drive the keyboard from code

```dart
final controller = VirtualKeypadController();

controller.insertText('Hello');
controller.deleteBackward();
controller.selectAll();
controller.clear();
controller.cursorPosition = 5;
controller.moveCursorLeft();
controller.moveCursorRight();
```

### Focused imports

Import only the surface you use:

| Import | Best for |
|---|---|
| `package:virtual_keypad/virtual_keypad.dart` | Everything: widgets, layouts, themes, helpers |
| `package:virtual_keypad/standalone.dart` | Standard `TextField` integration |
| `package:virtual_keypad/widgets.dart` | Scoped workflows with `VirtualKeypadScope` |
| `package:virtual_keypad/layouts.dart` | Language registration and custom layouts |

## Supported languages

All 14 are registered when you call `initializeKeyboardLayouts()`. Six of them
are pictured in the [Overview](#overview).

| Code | Language | Native name | Layout | Script | RTL |
|---|---|---|---|---|---|
| `ar` | Arabic | العربية | Arabic IBM PC | Arabic | ✅ |
| `bn` | Bengali | বাংলা | Bengali | Bengali | |
| `de` | German | Deutsch | QWERTZ | Latin | |
| `en` | English | English | QWERTY | Latin | |
| `es` | Spanish | Español | QWERTY (ES) | Latin | |
| `fr` | French | Français | AZERTY | Latin | |
| `hi` | Hindi | हिन्दी | Devanagari | Devanagari | |
| `it` | Italian | Italiano | QWERTY (IT) | Latin | |
| `ko` | Korean | 한국어 | Dubeolsik (두벌식) | Hangul | |
| `pt` | Portuguese | Português | QWERTY (PT) | Latin | |
| `ru` | Russian | Русский | ЙЦУКЕН (JCUKEN) | Cyrillic | |
| `th` | Thai | ไทย | Kedmanee | Thai | |
| `tr` | Turkish | Türkçe | QWERTY (TR) | Latin | |
| `uk` | Ukrainian | Українська | ЙЦУКЕН (JCUKEN) | Cyrillic | |

> Spot a wrong character, a missing key, or a layout that does not match the real
> thing for a language you speak? Please
> [open a pull request](https://github.com/almasumdev/virtual_keypad/pulls).
> Community fixes are very welcome.

## Common setup mistakes

- Forgetting `initializeKeyboardLayouts()` before `runApp()`. Built-in layouts are registered there, so nothing renders without it.
- Mixing standalone mode and scope mode in the same form. Pick one architecture per flow.
- Passing `customLayout` without `type: KeyboardType.custom`, or the reverse.
- Expecting `VirtualKeypadTextField` to allow the system keyboard. It blocks physical and system keyboard input unless you pass `allowPhysicalKeyboard: true`.

## FAQ

**Does it replace the system keyboard across the whole device?**
No. virtual_keypad is an in-app keyboard widget, not an Android IME or an iOS
keyboard extension. It draws inside your app and only affects your app.

**Which platforms are supported?**
Android, iOS, Web, Windows, macOS, and Linux. It is pure Dart and Flutter with
no native code, so there is nothing to configure per platform.

**Can I use it with a plain TextField?**
Yes. Pass `standalone: true` and it attaches to any focused `TextField` or
`TextFormField` with no other changes to your code.

**Can I stop the system keyboard from appearing?**
Yes. Use scope mode with `VirtualKeypadTextField`, which blocks physical and
system keyboard input by default.

**How do I build a PIN pad or OTP keypad?**
Set `type: KeyboardType.custom` and pass your own `customLayout`. See
[Build a PIN pad or numeric keypad](#build-a-pin-pad-or-numeric-keypad).

**Is it good for kiosk, ATM, and POS screens?**
That is the main use case. Floating mode with persistent visibility keeps the
keypad available on self-service terminals where no physical keyboard exists.

**Can I add a language that is not built in?**
Yes. Build a `KeyboardLanguage` with your own `KeyboardLayoutSet` and register
it through `KeyboardLayoutProvider.instance.registerLanguage()`.

**Does it work with right-to-left languages?**
Yes. Arabic ships with an RTL layout, and any language you register can set
`isRTL: true`.

## Support and feedback

- Found a bug or want a feature? Open an issue on the
  [issue tracker](https://github.com/almasumdev/virtual_keypad/issues).
- Questions and ideas are welcome via
  [GitHub Discussions](https://github.com/almasumdev/virtual_keypad/discussions).
- Pull requests are welcome; see the
  [Contributing Guide](https://github.com/almasumdev/virtual_keypad/blob/main/CONTRIBUTING.md).

## About

virtual_keypad is an open-source, MIT-licensed on-screen keyboard and keypad
widget for Flutter, built for apps that cannot rely on the system keyboard:
kiosks, ATMs, point of sale terminals, touchscreen and desktop software, and
secure PIN entry.

virtual_keypad is created and owned by **Nurullah Al Masum**.

It bundles [Noto Emoji](https://fonts.google.com/noto/specimen/Noto+Emoji),
subset to the codepoints used by the emoji picker, for offline emoji rendering
on the web. Noto Emoji is licensed under the SIL Open Font License 1.1; the full
license text ships in
[`fonts/OFL.txt`](https://github.com/almasumdev/virtual_keypad/blob/main/fonts/OFL.txt).

### Contributors

virtual_keypad grows with its community; every contributor is listed here:

<a href="https://github.com/almasumdev/virtual_keypad/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=almasumdev/virtual_keypad" alt="virtual_keypad contributors"/>
</a>

Want to help? Pull requests are welcome; see [Support and feedback](#support-and-feedback).
