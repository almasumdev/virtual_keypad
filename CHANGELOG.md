## 1.6.0

The emoji page can be driven by a remote, which closes the last item the roadmap
listed.

### New

- **D-pad navigation inside the emoji page.** With `enableDpadNavigation` on,
  the emoji page swaps its touch grid for one a directional pad can drive: a
  row of category icons across the top, the emoji below, arrow keys to move and
  select, enter or the primary gamepad button to insert.
- Moving up from the top row of the grid returns to the category strip, and up
  again closes the page and goes back to the letters.

### Fixed

- **The emoji page ignored the remote entirely.** D-pad handling was switched
  off whenever the emoji picker was showing, and the picker's own cells are not
  focusable, so on a TV the page opened and nothing responded, with no way to
  get back to the keyboard short of a touchscreen.

### Notes

The touch picker is still the default and is completely unchanged. The new view
appears only when `enableDpadNavigation` is on, so nothing moves for anyone not
driving the keyboard with a remote, and the new grid stays tappable for devices
that have both.

## 1.5.0

Reshuffle on demand, not only when the keypad appears.

### New

- `VirtualKeypad.shuffleTrigger` takes a `Listenable` and draws a fresh digit
  arrangement each time it fires. `KeyShuffle.onShow` only reshuffles when the
  keypad appears, which left no way to reshuffle during an entry: after a wrong
  PIN the keypad is already on screen, and that is exactly the moment a watcher
  has learned the most. Fire a `ChangeNotifier` to force a new arrangement.
- Ignored when `keyShuffle` is `KeyShuffle.none`. Swapping the listenable moves
  the subscription, and it is released when the keypad is disposed, so firing a
  trigger afterwards is harmless. You own the listenable and its disposal.

## 1.4.0

Scramble the digits, for PIN and payment entry.

### New

- `VirtualKeypad.keyShuffle` rearranges the digit keys. A fixed keypad leaks a
  PIN to anyone watching the hand or to a camera above the terminal, because
  finger positions are enough on their own. `KeyShuffle.onShow` reshuffles each
  time the keypad appears, which is what payment terminals do: positions hold
  still while someone is typing, so entry stays usable, but nothing carries from
  one entry to the next. `KeyShuffle.onEveryKey` reshuffles after every press,
  for maximum resistance at a real cost to usability. The default is
  `KeyShuffle.none`, so nothing changes unless you ask.
- Only single digits move. Backspace, the decimal point and every other key stay
  where they were, and the permutation is applied to a copy so the full set of
  digits is always on screen; a shuffle can never drop or duplicate one.
- `shuffleDigitKeys` is exported from `package:virtual_keypad/layouts.dart` for
  applying the same permutation to a custom layout.

### Fixed

- The security policy said to "use the shuffled layouts" for shoulder surfing.
  No such feature existed when that was written. It does now, and the policy
  names the actual API.

## 1.3.0

Draw a key yourself when a theme is not enough.

### New

- `VirtualKeypad.keyBuilder` replaces the content of a key. It is handed a
  `VirtualKeyContext` carrying the key, its resolved label (null for a key drawn
  as an icon), the current shift and caps lock, whether the key is the D-pad
  target, and the theme in force. Returning `null` declines that key and the
  package draws it normally, so overriding one key out of forty does not mean
  reimplementing the other thirty-nine.
- The builder controls content only. Background, size, tap handling, key repeat,
  D-pad focus and accessibility stay with the package, so a builder cannot break
  the keyboard's behaviour. A replaced key still reports presses as before.

## 1.2.0

Give the system keyboard back when the keypad is gone, and put your own font on
the keys.

### Fixed

- **Standalone mode left the system keyboard suppressed after the keypad was
  disposed.** `TextInput.setInputControl` replaces the platform text input
  control for the whole application and it stays replaced until it is handed
  back, which never happened. Any app that showed a `VirtualKeypad(standalone:
  true)` on one screen and ordinary `TextField`s on another ended up with no
  keyboard at all on those other fields, for the rest of the session. The
  control is now restored on dispose, and there are tests covering both halves:
  the keyboard stays suppressed while a standalone keypad is alive, and works
  again once it is gone.

### New

- `VirtualKeypadTheme.keyTextStyle` sets the text style for key labels. It is
  merged over `keyTextColor` and `keyTextSize`, so naming only a font family or
  weight keeps the themed colour and size, and setting `fontSize` or `color`
  inside the style overrides them. Kiosk and point of sale builds can finally
  put their brand font on the keys. Icons on action keys still follow
  `keyTextColor` and `keyTextSize`, since a font family does not apply to them.

### Changed

- The declared Flutter floor moves from 3.0.0 to 3.3.0. Standalone mode has
  always called `TextInput.setInputControl`, which landed in 3.3, so the old
  floor never actually built. This documents what was already required.

### Docs

- Theming guide and site page cover `keyTextStyle`, and the example app has a
  Branded preset that uses it.

## 1.1.1

### Changed

- The documentation website moved to https://virtual-keypad-docs.web.app.
  1.1.0 shipped pointing at the previous address, which still works and now
  redirects here, so no link is broken either way.

## 1.1.0

Key press feedback, and a documentation website.

### New

- `KeyFeedback` and a `feedback` parameter on `VirtualKeypad` and
  `VirtualKeypadFloating`. A touchscreen gives no tactile confirmation on its
  own, and on a kiosk or POS terminal the key preview is often the only signal
  that a tap registered at all. Four values: `sound` (the default), `haptic`,
  `both`, and `none`.
- Feedback now fires from the one place every key press goes through, so a
  D-pad activation on a television is confirmed the same way a tap is. It
  previously came from Material's ink response, which only ever saw taps.
- Both effects are handled by the platform, so there is no asset to bundle.
  A device with no vibration motor or no key click skips that effect instead of
  failing, and both follow the user's system settings including silent mode.

### Changed

- The default, `KeyFeedback.sound`, reproduces what the keyboard already did:
  Material played the platform key click on Android. Existing apps sound the
  same as before unless they ask for something else.
- Added a documentation website at https://virtual-keypad-docs.web.app, with guides
  for using any TextField, numeric and PIN pads, the floating panel, kiosk and
  POS screens, Android TV and D-pad, custom layouts, theming, languages and
  RTL, emoji, and troubleshooting. Linked from the package page through the new
  `documentation` field.

## 1.0.1

### Improved
* Restored `customizable` as an indexed keyword. The 1.0.0 description traded it for the kiosk, POS, and numpad terms and no other file carried the word, so pub.dev stopped returning the package for "customizable keyboard" entirely
* Repository links now point at `almasumdev/virtual_keypad`, the current location, instead of relying on GitHub's redirect from the old path
* Added a `.mailmap` so the several git identities behind each contributor collapse to one entry

---

## 1.0.0

First stable release. Everything below is additive, so upgrading from 0.8.1
needs no code changes. The API is settled from here and follows semantic
versioning.

### Added
* Bundled Noto Emoji font, subset to the 1271 codepoints the emoji picker uses (708 KB), applied on Flutter web only so native platforms keep their own color emoji font
* `colorEmojiFontLoader` on `VirtualKeypad` and `VirtualKeypadFloating` for loading a color emoji font at runtime on web, so apps can have color emoji without carrying a 3.9 MB font in the bundle. The bundled monochrome font paints immediately and the keyboard swaps to color once the font arrives; a failed load keeps the monochrome font so emoji always render. Off by default, and the package performs no fetch of its own
* `VirtualKeypadColorEmoji` with the registered family name and a memoized loader shared across keyboards. Font bytes are checked against the TrueType and OpenType signatures first, so a captive portal or error page served in place of the font is rejected instead of registering as an unrenderable font
* `kBundledEmojiFontFamily` constant and a `ThemeData.withVirtualKeypadEmojiFont()` extension for covering emoji inserted into your own `TextField` widgets in standalone mode
* `VirtualKeypadTextField` now appends the bundled emoji font as a fallback on web automatically, so emoji inserted in scope mode render offline with no setup
* `emojiTextStyle` on `VirtualKeypad` and `VirtualKeypadFloating` to override the emoji page font, for example to ship a color emoji font on web
* `checkEmojiPlatformCompatibility` on `VirtualKeypad` and `VirtualKeypadFloating` to opt into filtering emoji the device cannot render (Android only, off by default)
* D-pad and remote control navigation with `enableDpadNavigation` on `VirtualKeypad` and `VirtualKeypadFloating`, making the keyboard usable on Android TV, Fire TV, and set-top boxes. Arrow keys move a highlight, select, enter, or the primary gamepad button presses the key, and vertical moves land on the nearest key horizontally so wide keys stay reachable
* `focusBorderColor`, `focusBorderWidth`, and `focusColor` on `VirtualKeypadTheme` for styling the D-pad highlight

### Fixed
* Emoji rendered as blank boxes on a first offline load on Flutter web, where the CanvasKit and Skwasm renderers wait on an on-demand Noto fallback font download. The bundled font now makes the emoji page render offline with no app-side setup
* Emoji were spread far apart on wide keyboards, because the grid was capped at 12 columns regardless of width. Column count is now derived from the available width and the emoji size

### Improved
* Example app rebuilt as a single page where keyboard type, language, theme, emoji, floating mode, and D-pad navigation are each one chip or switch
* New package logo and two preview sheets showing the layouts and the built-in language scripts side by side, at scale against each other
* Package description and topics reworked for pub.dev search
* CI split into separate check, web compile, pana, and release stages, with an explicit gate at 160 pub points

---

## 0.8.1

### Improved
* Refreshed the README and pub.dev preview media to use the new `previews/` phone and desktop demo GIFs
* Added a dedicated floating mode guide and linked it from the API reference and README documentation section
* Added a compact static keyboard screenshot as the leading pub.dev package preview for the right-side media panel

### Fixed
* Standalone example now opens on the normal keyboard page instead of the emoji page by default
* Package metadata now points at the current preview media instead of the removed `images/` GIF set

---

## 0.8.0

### Added
* Opt-in emoji keyboard support on supported text layouts with `enableEmojiKey`
* Emoji-first presentation support with `showEmojiKeyboardInitially` for inline previews and always-visible emoji surfaces
* Embedded emoji browser powered by `emoji_picker_flutter` with categories, recents, and a keyboard-style action row

### Improved
* Example app screens now expose emoji across standalone, scoped, floating, and text-oriented demos
* Keyboard Preview example now includes a view-only emoji keyboard preview that follows the selected language
* Package metadata updated to describe emoji support in the release

### Fixed
* Inline keyboard width now respects parent constraints instead of assuming full screen width, avoiding overflow in constrained layouts
* Standalone emoji mode no longer collapses unexpectedly while the emoji browser is active

---

## 0.7.0

### Added
* `VirtualKeypadFloating` for draggable overlay-style keyboard presentation without changing existing inline integrations
* `VirtualKeypadFloatingController` and `VirtualKeypadFloatingVisibilityMode` for persistent manual visibility and dock controls
* Floating keyboard configuration for panel width, height, border radius, toolbar actions, and theme-aware overlay presentation

### Improved
* Example app screens now use a centered responsive content shell for better behavior across phone, tablet, desktop, and web layouts
* Floating keyboard example simplified into a single-scroll demo with standalone and scoped flows, size presets, theme presets, and non-round / less-round / round panel options
* README, example docs, and API reference updated for floating mode, persistent visibility, and release-ready integration guidance

### Fixed
* Floating keyboard now stays visible while the in-keyboard language picker menu is open
* Floating panel clipping and theming now apply consistently across the full toolbar and keyboard surface

---

## 0.6.1

### Improved
* Refined package metadata and keyword topics for the `0.6.1` release

---

## 0.6.0

### Added
* Distinct submit-style action reporting for both scoped and standalone integrations
  - `VirtualKeypadTextField.onInputAction`
  - `VirtualKeypad.onStandaloneInputAction`
* In-keyboard language switching with `availableLanguages`, `initialLanguage`, `onLanguageChanged`, and long-press space-bar language picker support
* Session-level language memory in `KeyboardLayoutProvider`
* Focused public entrypoints for documentation and selective imports
  - `package:virtual_keypad/widgets.dart`
  - `package:virtual_keypad/standalone.dart`
  - `package:virtual_keypad/layouts.dart`
* Contributor workflow templates for pull requests, onboarding friction reports, and accessibility issues

### Improved
* Release workflows now analyze the example app in CI and release gates
* README, API docs, and example docs expanded for standalone actions, language switching, focused imports, and deploy-facing package positioning
* Language registration now fails fast for malformed layouts, empty rows, invalid flex values, and missing character text
* Language switching example updated to reflect in-keyboard switching flow
* Pub.dev documentation navigation improved by exposing additional public libraries

### Fixed
* Custom submit-style action keys such as search, send, call, next, and previous now flow through the correct action path instead of collapsing into a generic submit behavior

---

## 0.5.1

### Fixed
* Shorten package description to comply with pub.dev 180-character limit

---

## 0.5.0

### Added
* **9 new keyboard languages**: Arabic (`ar`), German (`de`), Hindi (`hi`), Korean (`ko`), Portuguese (`pt`), Russian (`ru`), Spanish (`es`), Thai (`th`), and Turkish (`tr`), bringing the total to **12 built-in languages**
* Arabic layout with full RTL support (`isRTL: true`), Arabic-Indic numerals, diacritics, and Arabic punctuation (،/؟/؛)
* Korean Dubeolsik (두벌식) layout with shift for double consonants (ㅃㅉㄸㄲㅆ) and compound vowels (ㅒㅖ)
* Thai Kedmanee layout with Thai numerals (๑-๐), tone marks, and ฿ currency symbol
* Non-Latin scripts (Arabic, Bengali, Hindi, Korean, Russian, Thai) use Latin QWERTY for email/URL input types
* Native numeral support for Arabic (١-٠), Bengali (১-০), Hindi (१-०), and Thai (๑-๐) number pads with Western digit fallback via capsText
* Language dropdown selectors in Keyboard Preview and Language Switching example screens
* Localized hint text for all 12 languages in the Language Switching example

### Fixed
* Normalized key flex values across all layouts for consistent key sizing
* Visual alignment of action keys (shift, backspace, symbols) now uniform across languages

### Improved
* Keyboard Preview example now shows all layouts for the selected language

---

## 0.4.3

### Fixed
* Fix encoding corruption (mojibake) in French keyboard tertiary layout: all special characters (`€`, `•`, `√`, `π`, `÷`, `×`, `¶`, `∆`, `£`, `¥`, `¢`, `°`, `©`, `®`, `™`, `✓`) now display correctly
* Fix dartdoc warnings from unescaped doc references in `VirtualKeypadController`, `VirtualKey`, and `VirtualKeypad`
* `nativeName` for French language corrected from garbled text to `Français`

---

## 0.4.2

### Fixed
* Fix standalone keyboard breaking when navigating between pages that both use standalone mode: the previous page's `dispose` was restoring platform input control after the new page's `initState` had already set it (thanks @EArminjon, PR #7)
* Defer `setState` in standalone `onHide` callback via `addPostFrameCallback` to avoid calling it during build

---

## 0.4.1

### Fixed
* Skip opening virtual keyboard on read-only text fields (thanks @EArminjon, PR #6)

### Added
* CI workflow for auto-deploying example app to Firebase Hosting ([masum-vk.web.app](https://masum-vk.web.app))
* Live demo badge in README

---

## 0.4.0

### Added
* **`VirtualKeypadStandaloneScope`**: New widget that restricts a standalone-mode keyboard to only respond to text fields within its subtree. Useful for apps like Widgetbook where multiple widget previews are shown simultaneously.
* `VirtualKeypadStandaloneScope.maybeOf(context)` static method to look up the nearest scope.
* Scope-aware focus handling in `VirtualKeypad`: the keyboard now hides when focus moves to a text field outside its scope.
* Tests for `VirtualKeypadStandaloneScope` (`maybeOf` null case, ancestor lookup, sibling scope isolation).

### Fixed
* Dart formatting applied consistently across all example files to satisfy CI checks.

---

## 0.3.1

* Re-release of 0.3.0 (publish fix)

---

## 0.3.0

### Added
* **Standalone mode**: `VirtualKeypad(standalone: true)` works with any standard Flutter `TextField` or `TextFormField` without requiring `VirtualKeypadScope` or `VirtualKeypadTextField`. The keyboard intercepts Flutter's text input system and routes key presses to whichever field has focus.
* `StandaloneInputControl`: exported `TextInputControl` implementation that powers standalone mode.
* Auto-detects `TextInputType` from the focused field and adapts keyboard layout accordingly.
* **French (AZERTY) keyboard**: full text, email, URL, number, and phone layouts (`'fr'`).
* **`inputAction` parameter** on `VirtualKeypad`: override the enter/done key action label directly.
* **Smart enter key**: shows action label (Done, Go, Search, Send, Next) for non-multiline keyboards; shows return icon for multiline.
* `onKeyPressedWithText` callback: fires with `(VirtualKey key, String? text)`, where `text` is the actual inserted character (respecting shift/caps), or `null` for action keys.
* Standalone mode example screen in the example app.
* French language added to the language switching example.

---

## 0.2.1

### Improved
* Optimized package topics for better pub.dev discoverability
* Added preview GIFs to README

---

## 0.2.0

### Added
* **Key press preview popup** - Native-style key preview bubble appears above typed key
* Premium example app with 9 fully designed demo screens
* Preview GIFs in README

### Improved
* Redesigned example app UI for all screens with gradient themes and animations
* Simplified and restructured documentation for clarity
* Reorganized project assets

---

## 0.1.1

### Fixed
* **Physical keyboard handling** - Virtual keyboard now correctly hides when `allowPhysicalKeyboard: true`
* **Layout persistence on close** - Keyboard maintains its layout during close animation instead of resetting to default
* **Selection handling** - `insertText()` and `deleteBackward()` now properly handle text selections

### Added
* `selectAll()` method to `VirtualKeypadController` for selecting all text
* Stricter lint rules for better code quality
* Comprehensive documentation in `doc/` folder
  - API Reference
  - Custom Layouts Guide
  - Adding Languages Guide
  - Theming Guide

### Improved
* Enhanced `VirtualKeypadController` selection awareness
* Better scope state management for physical keyboard mode
* Professional README with cleaner structure

---

## 0.1.0

### Initial Release
* **VirtualKeypadScope** - Manages keyboard-to-textfield connections
* **VirtualKeypadTextField** - Text field with virtual keyboard integration
* **VirtualKeypad** - Customizable on-screen keyboard widget
* **VirtualKeypadController** - Controller with text manipulation methods
* **VirtualKeypadTheme** - Light, dark, and custom themes
* Multiple keyboard types: text, email, URL, number, phone
* Multi-language support: English (QWERTY) and Bengali (বাংলা)
* Input-type-aware layouts that adapt automatically
* Cross-platform support (mobile, web, desktop)
