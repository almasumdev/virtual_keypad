# -*- coding: utf-8 -*-
import io, os, json, re, hashlib, glob, shutil

def emit_asset(src, name, ext):
    """Copy an asset under a content-hashed name and return its URL.

    The hash is the cache key: a changed file gets a new URL, so the long
    immutable cache in firebase.json can never serve a stale pair of HTML
    and CSS. Stale hashed copies from earlier builds are removed first.
    """
    data = io.open(src, 'rb').read()
    digest = hashlib.sha256(data).hexdigest()[:10]
    for old in glob.glob(os.path.join(OUT, name + '.*.' + ext)):
        os.remove(old)
    out = '%s.%s.%s' % (name, digest, ext)
    io.open(os.path.join(OUT, out), 'wb').write(data)
    return '/' + out


BASE    = "https://virtual-keypad-docs.web.app"
OUT     = "site"
VERSION = "1.1.1"
# IndexNow verification key. Must stay in step with the file emitted
# at the site root, or Bing and Yandex reject the submission.
INDEXNOW_KEY = "5e83b1d0c74a29f6ab35ed80c1927f4b"

# Sidebar groups. Structure mirrors how the task is approached, not file order.
GROUPS = [
    ("Start here", [
        ("index",              "Introduction"),
        ("standalone-mode",    "Use any TextField"),
        ("numeric-keypad-pin", "Numeric and PIN pads"),
    ]),
    ("Modes", [
        ("floating-keyboard", "Floating panel"),
        ("kiosk-and-pos",     "Kiosk and POS"),
        ("android-tv",        "Android TV and D-pad"),
    ]),
    ("Customizing", [
        ("custom-layouts",    "Custom layouts"),
        ("theming",           "Theming"),
        ("languages-and-rtl", "Languages and RTL"),
        ("emoji-keyboard",    "Emoji"),
    ]),
    ("Help", [
        ("troubleshooting", "Troubleshooting"),
    ]),
]
NAV = [(s, t) for _, items in GROUPS for s, t in items]

ICON_GITHUB = ('<svg viewBox="0 0 16 16" aria-hidden="true" width="16" height="16" fill="currentColor"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27s1.36.09 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z"/></svg>')

ICON_MENU = ('<svg viewBox="0 0 24 24" aria-hidden="true" width="20" height="20" fill="none" stroke="currentColor" '
             'stroke-width="2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>')
ICON_CLOSE = ('<svg viewBox="0 0 24 24" aria-hidden="true" width="20" height="20" fill="none" stroke="currentColor" '
              'stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"/></svg>')

def slugify(text):
    t = re.sub(r"<[^>]+>", "", text)
    t = t.replace("&amp;", "and").replace("&lt;", "").replace("&gt;", "")
    t = re.sub(r"[^a-zA-Z0-9\s-]", "", t).strip().lower()
    return re.sub(r"[\s-]+", "-", t)

def add_heading_ids(body):
    """Give every h2 an id and collect them for the on-page contents list."""
    items = []
    def repl(m):
        text = m.group(1)
        sid = slugify(text)
        items.append((sid, re.sub(r"<[^>]+>", "", text)))
        return '<h2 id="%s">%s<a class="anchor" href="#%s" aria-label="Link to this section">#</a></h2>' % (sid, text, sid)
    return re.sub(r"<h2>(.*?)</h2>", repl, body, flags=re.S), items

def sidebar_html(slug):
    out = []
    for group, items in GROUPS:
        out.append('<h2>%s</h2><ul>' % group)
        for s, label in items:
            href = "/" if s == "index" else "/" + s
            cur = ' aria-current="page"' if s == slug else ""
            out.append('<li><a href="%s"%s>%s</a></li>' % (href, cur, label))
        out.append('</ul>')
    return "".join(out)


def toc_html(items):
    if len(items) < 2:
        return ""
    lis = "".join('<li><a href="#%s">%s</a></li>' % (sid, text) for sid, text in items)
    return ('<aside class="toc"><nav aria-labelledby="toc-h">'
            '<h2 id="toc-h">On this page</h2><ul>%s</ul></nav></aside>' % lis)


def page(slug, title, desc, h1, lede, body, faq=None):
    canonical = BASE + "/" + ("" if slug == "index" else slug)
    body, headings = add_heading_ids(body)

    # Wrap code blocks and tables so the copy button and overflow behave.
    body = body.replace("<pre><code>", '<div class="codeblock"><pre><code>')
    body = body.replace("</code></pre>", "</code></pre></div>")
    body = body.replace("<table>", '<div class="tablewrap"><table>')
    body = body.replace("</table>", "</table></div>")

    ld = {
        "@context": "https://schema.org",
        "@type": "TechArticle",
        "headline": h1,
        "description": desc,
        "url": canonical,
        "author": {"@type": "Person", "name": "Nurullah Al Masum"},
        "about": {"@type": "SoftwareSourceCode",
                  "name": "virtual_keypad",
                  "programmingLanguage": "Dart",
                  "codeRepository": "https://github.com/almasumdev/virtual_keypad"},
    }
    blocks = ['<script type="application/ld+json">%s</script>' % json.dumps(ld)]
    if faq:
        blocks.append('<script type="application/ld+json">%s</script>' % json.dumps({
            "@context": "https://schema.org", "@type": "FAQPage",
            "mainEntity": [{"@type": "Question", "name": q,
                            "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in faq]
        }))

    return """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>%(title)s</title>
<meta name="description" content="%(desc)s">
<link rel="canonical" href="%(canonical)s">
<meta property="og:type" content="article">
<meta property="og:title" content="%(title)s">
<meta property="og:description" content="%(desc)s">
<meta property="og:url" content="%(canonical)s">
<meta name="twitter:card" content="summary">
<link rel="icon" href="/logo.svg" type="image/svg+xml">
<link rel="stylesheet" href="%(css)s">
%(ld)s
</head>
<body>
<a class="skip" href="#content">Skip to content</a>

<header class="topbar">
  <button class="menu" type="button" aria-label="Open navigation" aria-expanded="false" aria-controls="sidebar">%(menu)s</button>
  <a class="brand" href="/"><img src="/logo.svg" alt="" width="24" height="24">virtual_keypad</a>
  <span class="ver">v%(version)s</span>
  <div class="grow"></div>
  <a class="ext" href="https://pub.dev/packages/virtual_keypad"><span>pub.dev</span></a>
  <a class="ext" href="https://github.com/almasumdev/virtual_keypad" aria-label="Source on GitHub">%(gh)s<span>GitHub</span></a>
</header>

<div class="scrim" aria-hidden="true"></div>

<div class="shell">
  <nav class="sidebar" id="sidebar" aria-label="Documentation">%(side)s</nav>

  <main class="content" id="content">
    <article>
      <h1>%(h1)s</h1>
      <p class="lede">%(lede)s</p>
      %(body)s
      <footer class="pagefoot">
        virtual_keypad is open source under the MIT licence.
        <a href="https://pub.dev/packages/virtual_keypad">pub.dev</a> &middot;
        <a href="https://github.com/almasumdev/virtual_keypad">Source</a> &middot;
        <a href="https://pub.dev/documentation/virtual_keypad/latest/">API reference</a>
      </footer>
    </article>
  </main>

  %(toc)s
</div>

<script src="%(js)s" defer></script>
</body>
</html>
""" % dict(title=title, desc=desc, canonical=canonical, ld="\n".join(blocks),
           menu=ICON_MENU, gh=ICON_GITHUB, version=VERSION,
           side=sidebar_html(slug), h1=h1, lede=lede, body=body,
           css=CSS_URL, js=JS_URL,
           toc=toc_html(headings))


INSTALL = """<h2>Install</h2>
<pre><code>flutter pub add virtual_keypad</code></pre>
<pre><code>import 'package:virtual_keypad/virtual_keypad.dart';</code></pre>"""


def nxt(pairs):
    return ('<nav class="next" aria-label="Related guides">'
            + "".join('<a href="/%s">%s</a>' % (s, t) for s, t in pairs)
            + "</nav>")


os.makedirs(OUT, exist_ok=True)
CSS_URL = emit_asset('tool/docs_assets/style.css', 'style', 'css')
JS_URL = emit_asset('tool/docs_assets/docs.js', 'docs', 'js')
print('  assets: %s  %s' % (CSS_URL, JS_URL))
def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def pre(code):
    return "<pre><code>%s</code></pre>" % esc(code.strip("\n"))

PAGES = []

# ---------------------------------------------------------------- index
PAGES.append(dict(
    slug="index",
    title="virtual_keypad - On-Screen Virtual Keyboard Widget for Flutter",
    desc="Open source Flutter package for an on-screen virtual keyboard and keypad. QWERTY, numeric, PIN, emoji and custom layouts in 16 languages, for kiosk, POS, TV and desktop apps.",
    h1="An on-screen keyboard for Flutter",
    lede="A virtual keyboard widget you draw yourself, for the screens where the system keyboard will not do.",
    body=INSTALL + """
<h2>Why draw your own keyboard</h2>
<p>The system keyboard is fine until it is not. A kiosk in fullscreen has none. A POS terminal needs a fixed pad that never covers the total. A TV has only a remote. A desktop app wants a keyboard the mouse can use. In all of those the input has to come from a widget you control.</p>

<h2>The smallest thing that works</h2>
<p>Add <code>standalone: true</code> and the keyboard finds the focused field on its own. No wrapper, no controller swap, no change to the form you already wrote.</p>
""" + pre("""
Column(
  children: [
    TextField(controller: controller),
    VirtualKeypad(standalone: true),
  ],
)
""") + """
<p>It reads each field's <code>keyboardType</code> and switches layout to match, so an email field gets <code>@</code> and <code>.</code> and a number field gets a numeric pad. See <a href="/standalone-mode">using it with any TextField</a>.</p>

<h2>What is in the box</h2>
<ul>
<li>QWERTY, email, URL, number, phone and multiline layouts, picked from the field.</li>
<li><a href="/numeric-keypad-pin">Numeric keypads and PIN pads</a> from a layout you define.</li>
<li>A <a href="/floating-keyboard">draggable floating panel</a> that sits above the UI instead of taking a slice of it.</li>
<li>16 languages including <a href="/languages-and-rtl">right to left</a>, with a long-press language picker on the space bar.</li>
<li>An <a href="/emoji-keyboard">emoji page</a> with a bundled font, so it renders on a first offline web load.</li>
<li><a href="/android-tv">D-pad navigation</a> for TV remotes and set-top boxes.</li>
<li><a href="/theming">Theming</a> down to key colour, radius, text size and the focus highlight.</li>
</ul>

<h2>Three ways to wire it up</h2>
<div class="tablewrap"><table>
<thead><tr><th>Mode</th><th>Use when</th></tr></thead>
<tbody>
<tr><td><code>standalone: true</code></td><td>You have ordinary <code>TextField</code>s and want the least change</td></tr>
<tr><td><code>VirtualKeypadScope</code></td><td>You want full control of the text through a controller</td></tr>
<tr><td><code>VirtualKeypadFloating</code></td><td>The keyboard should float over the UI and be draggable</td></tr>
</tbody></table></div>

<h2>Confirming a key press</h2>
<p>A touchscreen gives no tactile confirmation on its own, which on a kiosk is often the only signal that a tap registered.</p>
""" + pre("""
VirtualKeypad(feedback: KeyFeedback.both)   // click and a light vibration
""") + """
<p><code>KeyFeedback.sound</code> is the default and is what the keyboard already did. <code>haptic</code>, <code>both</code> and <code>none</code> are the other options.</p>

<h2>Where to start</h2>
<p>Wire it to <a href="/standalone-mode">an existing TextField</a> first. If you are building a payment or entry screen, go straight to <a href="/numeric-keypad-pin">numeric and PIN pads</a>. For a fullscreen terminal, read <a href="/kiosk-and-pos">kiosk and POS</a>.</p>
""" + nxt([("standalone-mode", "Use any TextField"), ("numeric-keypad-pin", "Numeric and PIN pads")]),
    faq=[("How do I show an on-screen keyboard in Flutter?",
          "Add VirtualKeypad(standalone: true) below your form. It finds the focused TextField on its own and matches its keyboardType, with no controller changes."),
         ("Can I use a virtual keyboard on Flutter desktop and web?",
          "Yes. The keyboard is a plain widget with no platform channels, so it runs on Android, iOS, Windows, macOS, Linux and web alike."),
         ("How do I build a PIN pad in Flutter?",
          "Pass type: KeyboardType.custom with a customLayout describing the keys. A four-row grid of digits plus backspace and done is the usual PIN pad.")],
))
print("defined index")

# ---------------------------------------------------------------- standalone
PAGES.append(dict(
    slug="standalone-mode",
    title="Use an On-Screen Keyboard with Any Flutter TextField",
    desc="Attach a virtual keyboard to the TextField widgets you already have in Flutter, keep the system keyboard from opening, and handle submit keys per field.",
    h1="Use any TextField",
    lede="One flag, no wrapper widgets, and the form you already wrote stays as it is.",
    body=INSTALL + """
<h2>Standalone mode</h2>
""" + pre("""
Column(
  children: [
    TextField(controller: emailController),
    TextField(controller: passwordController),
    VirtualKeypad(standalone: true),
  ],
)
""") + """
<p>The keyboard watches focus and types into whichever field has it. Your controllers, validators and <code>onChanged</code> callbacks all keep working, because the text goes in through the normal editing path rather than around it.</p>

<h2>The layout follows the field</h2>
<p>Each field's <code>keyboardType</code> picks the layout, so you do not configure the keyboard per field.</p>
<div class="tablewrap"><table>
<thead><tr><th>Field</th><th>Layout</th></tr></thead>
<tbody>
<tr><td><code>TextInputType.emailAddress</code></td><td>QWERTY with <code>@</code> and <code>.</code> on the main page</td></tr>
<tr><td><code>TextInputType.url</code></td><td>QWERTY with <code>/</code>, <code>:</code> and <code>.</code></td></tr>
<tr><td><code>TextInputType.number</code></td><td>Numeric pad</td></tr>
<tr><td><code>TextInputType.phone</code></td><td>Dialer</td></tr>
<tr><td><code>TextInputType.multiline</code></td><td>QWERTY with a newline key</td></tr>
</tbody></table></div>
<p>Pass <code>type:</code> on the keypad to override that and pin one layout for every field.</p>

<h2>Keeping the system keyboard shut</h2>
<p>On a phone or tablet both keyboards would otherwise appear. Standalone mode suppresses the system one for the fields it drives, so you do not need <code>readOnly: true</code> or a focus node that refuses focus. Those tricks also kill the caret and selection, which is why they are worth avoiding.</p>

<h2>Submit keys</h2>
<p>Use <code>onStandaloneInputAction</code> to tell submit-style keys apart at the keyboard level, which is how a dialer or a search bar gets wired.</p>
""" + pre("""
VirtualKeypad(
  standalone: true,
  onStandaloneInputAction: (action, text) {
    switch (action) {
      case KeyAction.next:
        FocusScope.of(context).nextFocus();
      case KeyAction.done:
      case KeyAction.search:
        submit(text);
      default:
        break;
    }
  },
)
""") + """
<p>The callback receives the action and the field's current text, so a search bar can submit the query without reaching for the controller. The key's label follows each field's <code>textInputAction</code>, so a field marked <code>next</code> shows a next key and the one after shows done.</p>

<h2>Hiding it when nothing is focused</h2>
""" + pre("""
VirtualKeypad(
  standalone: true,
  hideWhenUnfocused: true,
  animationDuration: const Duration(milliseconds: 180),
)
""") + """
<p>Useful on a phone-sized layout, where 280 pixels of keyboard under an unfocused form is wasted space. On a kiosk you usually want the opposite, so leave it off.</p>

<h2>When to reach for scope mode instead</h2>
<p>Standalone mode is the right default. Move to <code>VirtualKeypadScope</code> with <code>VirtualKeypadTextField</code> when you want to own the text yourself: reading the cursor position, inserting programmatically, or driving something that is not a <code>TextField</code> at all.</p>
""" + pre("""
final controller = VirtualKeypadController();

VirtualKeypadScope(
  child: Column(
    children: [
      VirtualKeypadTextField(controller: controller),
      const VirtualKeypad(),
    ],
  ),
)

controller.insertText('hello');
controller.deleteBackward();
""") + nxt([("numeric-keypad-pin", "Numeric and PIN pads"), ("floating-keyboard", "Floating panel")]),
    faq=[("How do I stop the system keyboard opening in Flutter?",
          "Use VirtualKeypad(standalone: true). It suppresses the system keyboard for the fields it drives while leaving the caret and selection working, unlike readOnly."),
         ("Does the virtual keyboard work with my existing TextEditingController?",
          "Yes. Standalone mode types through the normal editing path, so controllers, validators and onChanged callbacks behave exactly as before."),
         ("How do I handle the done or next key?",
          "Pass onStandaloneInputAction. The key label follows each field's textInputAction, so next and done can move focus or submit.")],
))
print("defined standalone")

# ---------------------------------------------------------------- numeric
PAGES.append(dict(
    slug="numeric-keypad-pin",
    title="Build a Numeric Keypad or PIN Pad in Flutter",
    desc="Create an on-screen numeric keypad, PIN pad or OTP entry in Flutter with a custom key layout, for checkout, ATM, POS and lock screens.",
    h1="Numeric and PIN pads",
    lede="A PIN pad is a custom layout, which means you decide exactly which keys exist and where.",
    body=INSTALL + """
<h2>The quickest numeric pad</h2>
<p>If you only want digits, a number field already gets one with no layout work.</p>
""" + pre("""
TextField(
  controller: controller,
  keyboardType: TextInputType.number,
)
// with VirtualKeypad(standalone: true) below it
""") + """
<h2>A PIN pad you control</h2>
<p>For a lock screen, an OTP box or a checkout, describe the grid yourself. This is the same mechanism ATM and POS flows use.</p>
""" + pre("""
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
    VirtualKey.action(action: KeyAction.done, label: 'OK'),
  ],
];

VirtualKeypad(
  type: KeyboardType.custom,
  customLayout: pinLayout,
)
""") + """
<p><code>customLayout</code> and <code>type: KeyboardType.custom</code> go together. Using one without the other asserts immediately in debug, so the mistake surfaces at once rather than as an empty keyboard.</p>

<h2>Making it look like a pad, not a keyboard</h2>
<p>A PIN pad wants big keys and few of them, so theme it rather than accepting keyboard defaults.</p>
""" + pre("""
VirtualKeypad(
  type: KeyboardType.custom,
  customLayout: pinLayout,
  height: 360,
  width: 320,
  theme: VirtualKeypadTheme.dark.copyWith(
    keyTextSize: 28,
    keyBorderRadius: 16,
    verticalGap: 10,
    horizontalGap: 10,
  ),
)
""") + """
<h2>Confirming each digit</h2>
<p>On a payment terminal a mis-registered digit is expensive, and the screen is often the only feedback the user gets.</p>
""" + pre("""
VirtualKeypad(
  type: KeyboardType.custom,
  customLayout: pinLayout,
  feedback: KeyFeedback.both,
)
""") + """
<h2>Reading the value</h2>
<p>Scope mode gives you the digits without going through a text field, which suits a PIN display made of dots.</p>
""" + pre("""
final pin = VirtualKeypadController();

pin.addListener(() {
  if (pin.text.length == 4) verify(pin.text);
});
""") + """
<h2>Wider keys</h2>
<p>A key's <code>flex</code> sets how many columns it spans, so a zero key can span two while the rest span one.</p>
""" + pre("""
[
  VirtualKey.character(text: '0', flex: 2),
  VirtualKey.action(action: KeyAction.backSpace),
]
""") + nxt([("custom-layouts", "Custom layouts"), ("kiosk-and-pos", "Kiosk and POS")]),
    faq=[("How do I make a PIN pad in Flutter?",
          "Pass type: KeyboardType.custom with a customLayout of digit keys plus backspace and done. The two parameters must be used together."),
         ("How do I show a numeric keypad instead of a full keyboard?",
          "Set the field's keyboardType to TextInputType.number and the keyboard switches to a numeric pad on its own, or define a custom layout for full control."),
         ("How do I make one key wider than the others?",
          "Give it a flex value. A key with flex: 2 spans two columns, which is how a wide zero or space key is built.")],
))
print("defined numeric")

# ---------------------------------------------------------------- floating
PAGES.append(dict(
    slug="floating-keyboard",
    title="A Draggable Floating Keyboard Panel in Flutter",
    desc="Show a movable on-screen keyboard panel that floats above your Flutter UI instead of taking a slice of the layout, with persistent visibility for kiosk screens.",
    h1="Floating panel",
    lede="The same keyboard in a panel the user can drag, sitting above the UI rather than inside it.",
    body=INSTALL + """
<h2>Why float it</h2>
<p>A docked keyboard takes 280 pixels off the bottom of the screen for as long as it is visible. On a form that is fine. On a map, a table, or a seating chart it hides the thing the user is trying to type about. A floating panel can be moved out of the way instead.</p>

<h2>The panel</h2>
""" + pre("""
VirtualKeypadFloating(
  standalone: true,
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
""") + """
<p><code>child</code> is your normal screen. The panel is drawn over it, so nothing in your layout shifts when the keyboard appears. Everything the docked keypad accepts works here too, including <code>enableEmojiKey</code>, <code>type</code>, <code>customLayout</code> and <code>feedback</code>.</p>

<h2>Keeping it on screen</h2>
<p>By default the panel follows focus and goes away when nothing is focused. On a kiosk or POS screen you usually want it always there, which is what persistent mode is for.</p>
""" + pre("""
final floating = VirtualKeypadFloatingController();

VirtualKeypadFloating(
  controller: floating,
  visibilityMode: VirtualKeypadFloatingVisibilityMode.persistent,
  width: 420,
  borderRadius: 20,
  child: MyScreen(),
)

floating.show();
floating.hide();
floating.toggle();
""") + """
<p>The controller is required in persistent mode, and the constructor asserts if it is missing, since a persistent panel with no way to dismiss it would trap the user.</p>

<h2>Docking</h2>
<p>The panel header carries dock-to-top and dock-to-bottom buttons alongside close, so a user who has dragged it somewhere awkward can snap it back without hunting for the right position.</p>

<h2>Width on a large screen</h2>
<p><code>maxWidth</code> caps how wide the panel grows, defaulting to 680. Without a cap, a full-width keyboard on a 27 inch POS display puts the two halves of QWERTY too far apart to use comfortably.</p>
""" + pre("""
VirtualKeypadFloating(
  maxWidth: 520,
  child: MyScreen(),
)
""") + """
<h2>Docked or floating</h2>
<div class="tablewrap"><table>
<thead><tr><th>Use</th><th>When</th></tr></thead>
<tbody>
<tr><td><code>VirtualKeypad</code></td><td>A form, where the keyboard belongs at the bottom and the layout can give up the space</td></tr>
<tr><td><code>VirtualKeypadFloating</code></td><td>The content underneath matters while typing, or the user should choose where the keyboard sits</td></tr>
</tbody></table></div>
<p>Floating mode is additive. Existing docked code keeps working unchanged.</p>
""" + nxt([("kiosk-and-pos", "Kiosk and POS"), ("theming", "Theming")]),
    faq=[("How do I make a draggable keyboard in Flutter?",
          "Wrap your screen in VirtualKeypadFloating. It draws a movable panel above the child, so the layout does not shift when the keyboard appears."),
         ("How do I keep the on-screen keyboard always visible?",
          "Pass a VirtualKeypadFloatingController and set visibilityMode to persistent. The controller is required so there is always a way to hide it."),
         ("Can the floating keyboard use a custom layout?",
          "Yes. It accepts everything the docked keypad does, including type, customLayout, enableEmojiKey and feedback.")],
))
print("defined floating")

# ---------------------------------------------------------------- kiosk
PAGES.append(dict(
    slug="kiosk-and-pos",
    title="An On-Screen Keyboard for Flutter Kiosk and POS Apps",
    desc="Set up a virtual keyboard for a Flutter kiosk, POS terminal or self-service screen, where there is no system keyboard and the layout must never move.",
    h1="Kiosk and POS",
    lede="Fullscreen terminals have no system keyboard, so the input has to come from a widget you control.",
    body=INSTALL + """
<h2>What makes a kiosk different</h2>
<p>Three things, and they push in the same direction. There is often no system keyboard at all, because the device is locked to one app. The screen is fixed, so a keyboard that slides in and pushes the layout is worse than one that is simply always there. And the user is a stranger who will not persist through a confusing screen.</p>

<h2>An always-visible pad</h2>
""" + pre("""
final floating = VirtualKeypadFloatingController(initialVisible: true);

VirtualKeypadFloating(
  controller: floating,
  visibilityMode: VirtualKeypadFloatingVisibilityMode.persistent,
  standalone: true,
  width: 720,
  maxWidth: 720,
  theme: VirtualKeypadTheme.dark,
  feedback: KeyFeedback.both,
  child: OrderScreen(),
)
""") + """
<p>Persistent visibility means the keyboard does not appear and disappear with focus, which on a terminal reads as the screen glitching rather than as a feature.</p>

<h2>Confirm every press</h2>
<p>A kiosk screen is often behind glass, under bright light, and touched by someone wearing gloves. The visual key preview may be the only confirmation, and it is easy to miss.</p>
""" + pre("""
VirtualKeypad(feedback: KeyFeedback.both)
""") + """
<p>Both effects follow the device's own settings, so a terminal with sound disabled stays silent and one with no vibration motor skips the haptic rather than failing.</p>

<h2>Size the keys for standing users</h2>
<p>Default key sizing assumes a phone held close. Someone standing at a terminal is further away and less accurate, so bigger keys and wider gaps reduce mistypes more than any other single change.</p>
""" + pre("""
VirtualKeypad(
  height: 340,
  theme: VirtualKeypadTheme.light.copyWith(
    keyTextSize: 26,
    keyBorderRadius: 10,
    horizontalGap: 8,
    verticalGap: 8,
  ),
)
""") + """
<h2>Numbers only, where that is all you need</h2>
<p>An order number, a table number or a PIN does not need QWERTY. A <a href="/numeric-keypad-pin">custom numeric layout</a> is faster to use and far harder to get wrong.</p>

<h2>More than one language</h2>
<p>Public terminals rarely serve one language. Pass the ones you support and users reach the picker by long-pressing space.</p>
""" + pre("""
VirtualKeypad(
  availableLanguages: ['en', 'ar', 'fr'],
  initialLanguage: 'en',
)
""") + """
<p>See <a href="/languages-and-rtl">languages and RTL</a> for what is built in and how right to left is handled.</p>
""" + nxt([("floating-keyboard", "Floating panel"), ("numeric-keypad-pin", "Numeric and PIN pads")]),
    faq=[("How do I add a keyboard to a Flutter kiosk app?",
          "Use VirtualKeypadFloating with a controller and persistent visibility, or a docked VirtualKeypad with standalone: true. Neither needs a system keyboard to be present."),
         ("Why is there no keyboard on my kiosk device?",
          "A device locked to one app often has no system keyboard available at all. Drawing your own with a widget is the reliable way to accept input there."),
         ("How do I make keys easier to hit on a terminal?",
          "Raise the keyboard height and the theme's keyTextSize, and widen horizontalGap and verticalGap. Defaults assume a phone held close, not someone standing at a screen.")],
))
print("defined kiosk")

# ---------------------------------------------------------------- tv
PAGES.append(dict(
    slug="android-tv",
    title="A D-Pad Navigable Keyboard for Flutter on Android TV",
    desc="Make an on-screen keyboard usable with nothing but a remote in Flutter, for Android TV, Fire TV and set-top boxes, including focus highlight styling.",
    h1="Android TV and D-pad",
    lede="On a television the only input device is a directional pad, so every key has to be reachable with four arrows and a select button.",
    body=INSTALL + """
<h2>Turning it on</h2>
""" + pre("""
VirtualKeypad(
  standalone: true,
  enableDpadNavigation: true,
  theme: VirtualKeypadTheme.dark.copyWith(
    focusBorderColor: Colors.amber,
    focusBorderWidth: 4,
  ),
)
""") + """
<p>One key is highlighted at a time. Arrow keys move the highlight, and select, enter or the primary gamepad button presses it.</p>

<h2>Moving between rows</h2>
<p>Keyboard rows are not the same length, so a naive index-based move lands somewhere unrelated when going up or down. Moving vertically picks the key in the next row that sits closest horizontally, which keeps wide keys such as space and shift reachable instead of being skipped past.</p>

<h2>Two decisions worth knowing about</h2>
<p><strong>Space does not press the highlighted key.</strong> Pairing a Bluetooth keyboard to a TV is common, and someone typing there expects space to type a space rather than fire whatever the highlight happens to be on.</p>
<p><strong>An arrow at the edge of the grid is left unhandled.</strong> That lets your app move focus off the keyboard and on to the rest of the screen, rather than trapping the user inside a grid they cannot leave.</p>

<h2>Make the highlight obvious</h2>
<p>A television is watched from across a room, so a subtle highlight is no highlight at all.</p>
""" + pre("""
VirtualKeypadTheme.dark.copyWith(
  focusBorderColor: Colors.amber,
  focusBorderWidth: 4,
  focusColor: Colors.amber.withValues(alpha: 0.15),
)
""") + """
<p><code>focusColor</code> fills the highlighted key, <code>focusBorderColor</code> outlines it. Using both reads better at distance than either alone.</p>

<h2>Confirming a press without a click</h2>
<p>A remote gives no tactile confirmation and a TV has no vibration motor, so sound is the only channel available.</p>
""" + pre("""
VirtualKeypad(
  enableDpadNavigation: true,
  feedback: KeyFeedback.sound,
)
""") + """
<p>Feedback fires for D-pad activation as well as taps, so the confirmation does not depend on how the key was reached.</p>

<h2>The emoji page too</h2>
<p>With <code>enableDpadNavigation</code> on, the emoji page swaps its touch grid for one the remote can drive: a row of category icons across the top, the emoji below, arrows to move and select to insert. Moving up from the top row goes back to the categories, and up again closes the page and returns to the letters, so the user is never stranded somewhere the remote cannot leave.</p>
<p>The grid is still tappable, so a device with both a touchscreen and a remote behaves the same way either side. Without <code>enableDpadNavigation</code> the usual touch picker is shown, unchanged.</p>

<h2>Only one keyboard responds</h2>
<p>If two keypads are mounted at once, only the visible one consumes a D-pad press. Without that rule a hidden keyboard offscreen would silently eat the remote input and the visible one would appear frozen.</p>
""" + nxt([("theming", "Theming"), ("standalone-mode", "Use any TextField")]),
    faq=[("How do I make a Flutter keyboard work with a TV remote?",
          "Set enableDpadNavigation: true. Arrow keys move a highlight between keys and select or enter presses the highlighted one."),
         ("Can the emoji picker be used with a TV remote?",
          "Yes, from 1.6.0. With enableDpadNavigation on, the emoji page shows a grid the D-pad can drive, with a category strip along the top; arrows move, select inserts, and moving up twice leaves the page."),
         ("Why does space not press the highlighted key?",
          "Because a Bluetooth keyboard paired to a TV is common, and space there should type a space. Select, enter and the primary gamepad button press the key."),
         ("How do I style the D-pad focus highlight?",
          "Use the theme's focusBorderColor, focusBorderWidth and focusColor. On a television, use a fill and an outline together so the highlight reads from across a room.")],
))
print("defined tv")

# ---------------------------------------------------------------- layouts
PAGES.append(dict(
    slug="custom-layouts",
    title="Custom Keyboard Layouts in Flutter",
    desc="Define your own on-screen key layout in Flutter, with character keys, action keys, key spans and multi-page layouts for calculators, forms and branded keypads.",
    h1="Custom layouts",
    lede="A layout is a list of rows, and a row is a list of keys. There is nothing else to it.",
    body=INSTALL + """
<h2>The shape</h2>
""" + pre("""
VirtualKeypad(
  type: KeyboardType.custom,
  customLayout: [
    [
      VirtualKey.character(text: 'a'),
      VirtualKey.character(text: 'b'),
    ],
    [
      VirtualKey.action(action: KeyAction.backSpace),
      VirtualKey.action(action: KeyAction.done),
    ],
  ],
)
""") + """
<p>Rows do not have to be the same length. Keys are laid out evenly across the width, so a short row simply gets wider keys.</p>

<h2>The two kinds of key</h2>
<div class="tablewrap"><table>
<thead><tr><th>Constructor</th><th>Does</th></tr></thead>
<tbody>
<tr><td><code>VirtualKey.character(text: 'a')</code></td><td>Inserts text at the cursor</td></tr>
<tr><td><code>VirtualKey.action(action: ...)</code></td><td>Runs a key action such as backspace, enter or done</td></tr>
</tbody></table></div>
<p>A character key is not limited to one character. <code>VirtualKey.character(text: '.com')</code> inserts all four, which is how a URL key or a currency shortcut is built.</p>

<h2>Labels</h2>
<p>A character key shows the text it inserts, and that is not configurable: what you see is what goes in. Action keys take a <code>label</code>, because an action has no inserted text to show.</p>
""" + pre("""
VirtualKey.action(action: KeyAction.backSpace, label: 'Del')
VirtualKey.action(action: KeyAction.done, label: 'Pay')
""") + """
<h2>Spanning columns</h2>
""" + pre("""
[
  VirtualKey.action(action: KeyAction.shift),
  VirtualKey.character(text: ' ', flex: 4),
  VirtualKey.action(action: KeyAction.backSpace),
]
""") + """
<p><code>flex</code> is a share of the row, so the space key above is four times the width of the keys either side of it.</p>

<h2>A worked example</h2>
<p>A calculator pad, where the operators sit in their own column.</p>
""" + pre("""
final calculator = [
  [
    VirtualKey.character(text: '7'),
    VirtualKey.character(text: '8'),
    VirtualKey.character(text: '9'),
    VirtualKey.character(text: '/'),
  ],
  [
    VirtualKey.character(text: '4'),
    VirtualKey.character(text: '5'),
    VirtualKey.character(text: '6'),
    VirtualKey.character(text: '*'),
  ],
  [
    VirtualKey.character(text: '1'),
    VirtualKey.character(text: '2'),
    VirtualKey.character(text: '3'),
    VirtualKey.character(text: '-'),
  ],
  [
    VirtualKey.character(text: '0', flex: 2),
    VirtualKey.character(text: '.'),
    VirtualKey.character(text: '+'),
  ],
];
""") + """
<h2>Reacting to keys yourself</h2>
<p><code>onKeyPressedWithText</code> reports both the key and the text it inserted, which is <code>null</code> for action keys.</p>
""" + pre("""
VirtualKeypad(
  type: KeyboardType.custom,
  customLayout: calculator,
  onKeyPressedWithText: (key, text) {
    if (text != null) log('inserted $text');
  },
)
""") + """
<h2>The one rule</h2>
<p><code>customLayout</code> requires <code>type: KeyboardType.custom</code>, and that type requires a layout. Either one alone asserts in debug, so a setup mistake fails loudly rather than rendering an empty keyboard you then have to diagnose.</p>
""" + nxt([("numeric-keypad-pin", "Numeric and PIN pads"), ("languages-and-rtl", "Languages and RTL")]),
    faq=[("How do I create a custom keyboard layout in Flutter?",
          "Pass type: KeyboardType.custom and a customLayout, which is a list of rows where each row is a list of VirtualKey values."),
         ("Can one key insert more than one character?",
          "Yes. VirtualKey.character takes any string, so a key can insert .com or a currency symbol and prefix together."),
         ("How do I make a space bar or a wide key?",
          "Give the key a flex value. It sets the key's share of the row, so flex: 4 makes it four times as wide as a flex: 1 neighbour.")],
))
print("defined layouts")

# ---------------------------------------------------------------- theming
PAGES.append(dict(
    slug="theming",
    title="Theming an On-Screen Keyboard in Flutter",
    desc="Style a Flutter virtual keyboard: key colours, corner radius, text size, shadows, gaps, ripple and the D-pad focus highlight, with light and dark presets.",
    h1="Theming",
    lede="Two presets to start from, and every property on them can be replaced.",
    body=INSTALL + """
<h2>The presets</h2>
""" + pre("""
VirtualKeypad(theme: VirtualKeypadTheme.light)
VirtualKeypad(theme: VirtualKeypadTheme.dark)
""") + """
<h2>Changing part of one</h2>
<p><code>copyWith</code> is almost always what you want. Building a theme from scratch means restating every colour, and a value you forget is a default rather than an error.</p>
""" + pre("""
VirtualKeypad(
  theme: VirtualKeypadTheme.dark.copyWith(
    keyBorderRadius: 12,
    keyTextSize: 24,
  ),
)
""") + """
<h2>A theme of your own</h2>
""" + pre("""
VirtualKeypad(
  theme: VirtualKeypadTheme(
    backgroundColor: Colors.grey[900]!,
    keyColor: Colors.grey[800]!,
    actionKeyColor: Colors.grey[700]!,
    keyTextColor: Colors.white,
    keyBorderRadius: 12,
  ),
)
""") + """
<h2>A font of your own</h2>
<p>Kiosk and point of sale builds usually have a brand font, and the keys should use it. <code>keyTextStyle</code> is merged over <code>keyTextColor</code> and <code>keyTextSize</code>, so you set only what you want to change.</p>
""" + pre("""
VirtualKeypad(
  theme: VirtualKeypadTheme.light.copyWith(
    keyTextStyle: const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  ),
)
""") + """
<p>A <code>fontSize</code> or <code>color</code> inside the style wins over <code>keyTextSize</code> and <code>keyTextColor</code> for the labels. Icons on action keys keep following the colour and size, since a font family does not apply to them.</p>
<h2>Every property</h2>
<div class="tablewrap"><table>
<thead><tr><th>Property</th><th>Type</th><th>Default</th><th>What it does</th></tr></thead>
<tbody>
<tr><td><code>backgroundColor</code></td><td><code>Color</code></td><td><code>#D1D3D9</code></td><td>Keyboard background</td></tr>
<tr><td><code>keyColor</code></td><td><code>Color</code></td><td><code>#FFFFFF</code></td><td>Character key background</td></tr>
<tr><td><code>actionKeyColor</code></td><td><code>Color</code></td><td><code>#ADB3BC</code></td><td>Action key background</td></tr>
<tr><td><code>keyTextColor</code></td><td><code>Color</code></td><td><code>#1C1C1E</code></td><td>Text and icon colour</td></tr>
<tr><td><code>keyTextSize</code></td><td><code>double</code></td><td><code>22.0</code></td><td>Font size</td></tr>
<tr><td><code>keyTextStyle</code></td><td><code>TextStyle?</code></td><td><code>null</code></td><td>Key label style, merged over the colour and size</td></tr>
<tr><td><code>keyBorderRadius</code></td><td><code>double</code></td><td><code>6.0</code></td><td>Corner radius</td></tr>
<tr><td><code>keyShadow</code></td><td><code>bool</code></td><td><code>true</code></td><td>Key shadows</td></tr>
<tr><td><code>splashColor</code></td><td><code>Color?</code></td><td><code>null</code></td><td>Tap ripple colour</td></tr>
<tr><td><code>horizontalGap</code></td><td><code>double</code></td><td></td><td>Space between keys in a row</td></tr>
<tr><td><code>verticalGap</code></td><td><code>double</code></td><td></td><td>Space between rows</td></tr>
<tr><td><code>focusBorderColor</code></td><td><code>Color?</code></td><td><code>keyTextColor</code></td><td>D-pad highlight border</td></tr>
<tr><td><code>focusBorderWidth</code></td><td><code>double</code></td><td><code>3.0</code></td><td>D-pad highlight border width</td></tr>
<tr><td><code>focusColor</code></td><td><code>Color?</code></td><td><code>null</code></td><td>D-pad highlight fill</td></tr>
</tbody></table></div>

<h2>Following the app theme</h2>
<p>The keyboard does not read <code>Theme.of(context)</code> on its own, because a keyboard often wants to differ from the surrounding app. Wire it up yourself when you do want it to match.</p>
""" + pre("""
final dark = Theme.of(context).brightness == Brightness.dark;

VirtualKeypad(
  theme: dark ? VirtualKeypadTheme.dark : VirtualKeypadTheme.light,
)
""") + """
<h2>Sizing for the screen</h2>
<p>Colour is the easy part. The change that matters most is key size, and it depends entirely on how far away the user is.</p>
<div class="tablewrap"><table>
<thead><tr><th>Screen</th><th>Reasonable starting point</th></tr></thead>
<tbody>
<tr><td>Phone</td><td>Defaults, held close and tapped with a thumb</td></tr>
<tr><td>Tablet or desktop</td><td><code>keyTextSize: 24</code>, a little more gap</td></tr>
<tr><td>Kiosk or POS</td><td><code>height: 340</code>, <code>keyTextSize: 26</code>, gaps at 8</td></tr>
<tr><td>Television</td><td>Dark theme, a strong focus highlight, large text</td></tr>
</tbody></table></div>
""" + nxt([("kiosk-and-pos", "Kiosk and POS"), ("android-tv", "Android TV and D-pad")]),
    faq=[("How do I change the keyboard colours in Flutter?",
          "Pass a VirtualKeypadTheme, or call copyWith on one of the light and dark presets to change only the properties you care about."),
         ("Does the virtual keyboard follow my app theme?",
          "Not automatically, since a keyboard often wants to differ from the app around it. Read Theme.of(context).brightness and pass the matching preset if you want it to follow."),
         ("How do I make the keys bigger?",
          "Raise the keyboard height and the theme's keyTextSize, and increase horizontalGap and verticalGap. Distance from the screen matters more than screen size.")],
))
print("defined theming")

# ---------------------------------------------------------------- languages
PAGES.append(dict(
    slug="languages-and-rtl",
    title="A Multi-Language and RTL Virtual Keyboard in Flutter",
    desc="Switch a Flutter on-screen keyboard between 16 built-in languages including Arabic right to left, offer a language picker, and register a layout of your own.",
    h1="Languages and RTL",
    lede="Sixteen layouts are built in, two of them right to left, and adding a seventeenth takes a map.",
    body=INSTALL + """
<h2>Registering the built-in layouts</h2>
""" + pre("""
void main() {
  initializeKeyboardLayouts();   // registers all 16 languages
  runApp(const MyApp());
}
""") + """
<p>Call it once at startup. Without it the keyboard falls back to English, which is the most common reason a language switch appears to do nothing.</p>

<h2>Switching</h2>
""" + pre("""
KeyboardLayoutProvider.instance.setLanguage('ar');   // Arabic, right to left
KeyboardLayoutProvider.instance.setLanguage('ko');   // Korean
KeyboardLayoutProvider.instance.setLanguage('en');   // English
""") + """
<h2>Letting the user choose</h2>
""" + pre("""
VirtualKeypad(
  availableLanguages: ['en', 'bn', 'ar'],
  initialLanguage: 'en',
  onLanguageChanged: (code) {
    prefs.setString('keyboardLanguage', code);
  },
)
""") + """
<p>With more than one entry, a long press on the space bar opens the picker. The first entry is that keyboard's fallback.</p>
<p>The selection lasts for the app session and is not persisted for you. Save the code from <code>onLanguageChanged</code> and pass it back as <code>initialLanguage</code> to restore it after a restart.</p>

<h2>Right to left</h2>
<p>Arabic and other right to left layouts lay their keys out in the correct direction, and text goes into the field the way the field already handles direction. That means an RTL layout works inside an LTR app without wrapping anything in a <code>Directionality</code> widget.</p>

<h2>Adding your own</h2>
<p>A layout is rows of keys, the same structure a <a href="/custom-layouts">custom layout</a> uses, registered under a language code.</p>
""" + pre("""
KeyboardLayoutProvider.instance.registerLanguage(
  const KeyboardLanguage(
    code: 'sv',
    name: 'Swedish',
    nativeName: 'Svenska',
    textLayouts: KeyboardLayoutSet(
      primary: [
        [
          VirtualKey.character(text: 'q'),
          VirtualKey.character(text: 'w'),
          // ... the rest of the row
        ],
      ],
      secondary: numberSymbolRows,   // the numbers page
    ),
  ),
);
""") + """
<p>Only <code>textLayouts</code> is required. Leave <code>emailLayouts</code>, <code>urlLayouts</code>, <code>numberLayouts</code> and the rest off and the language falls back for those field types. Set <code>isRTL: true</code> for a right to left script.</p>
<p>Register before the keyboard is built, then include the code in <code>availableLanguages</code>. A contribution back to the package is welcome if the layout is a standard one for that language.</p>

<h2>Shifted characters</h2>
<p><code>capsText</code> is what a key inserts while shift or caps lock is on.</p>
""" + pre("""
VirtualKey.character(text: 'a', capsText: 'A')
""") + """
<p>Without it a shifted key falls back to the uppercase form of its text, which is right for Latin scripts and wrong for any script where shift reaches a different character rather than a taller one.</p>
""" + nxt([("custom-layouts", "Custom layouts"), ("emoji-keyboard", "Emoji")]),
    faq=[("How do I add another language to the Flutter keyboard?",
          "Call initializeKeyboardLayouts at startup for the 16 built-ins, then pass availableLanguages. For a language that is not built in, register a KeyboardLayoutSet under its code."),
         ("Does the on-screen keyboard support Arabic and right to left?",
          "Yes. RTL layouts lay their keys out in the correct direction and work inside an LTR app without wrapping anything in a Directionality widget."),
         ("Why does switching language do nothing?",
          "initializeKeyboardLayouts was probably never called, so only English is registered. Call it once at startup before the keyboard is built.")],
))
print("defined languages")

# ---------------------------------------------------------------- emoji
PAGES.append(dict(
    slug="emoji-keyboard",
    title="Add an Emoji Keyboard to a Flutter App",
    desc="Show an emoji picker page inside a Flutter on-screen keyboard, with a bundled font so emoji render on a first offline web load.",
    h1="Emoji",
    lede="An emoji page behind a key on the keyboard, with the font problem on web already solved.",
    body=INSTALL + """
<h2>Turning it on</h2>
""" + pre("""
VirtualKeypad(
  standalone: true,
  enableEmojiKey: true,
)
""") + """
<p>That adds an emoji key to the layout. Press it and the keyboard swaps to the emoji page, with a key to come back.</p>
<p>To open on the emoji page instead of the letters, which suits a reaction picker or a comment box:</p>
""" + pre("""
VirtualKeypad(
  standalone: true,
  enableEmojiKey: true,
  showEmojiKeyboardInitially: true,
)
""") + """
<h2>Why a font ships with the package</h2>
<p>On web, Flutter downloads a fallback emoji font on demand. That works once the network has been there, and fails on a first offline load: the emoji page renders as blank boxes with no error to explain it.</p>
<p>The package bundles Noto Emoji, subset to the 1271 codepoints the picker actually uses, and applies it on web only. Native platforms keep their own colour emoji font, which is better than any font a package could ship.</p>

<h2>Colour emoji on web</h2>
<p>The bundled font is monochrome, which is the trade for a font small enough to bundle. If you want colour on web, supply a colour font and it is used instead.</p>
""" + pre("""
VirtualKeypad(
  enableEmojiKey: true,
  colorEmojiFontLoader: () async {
    final bytes = await rootBundle.load('assets/NotoColorEmoji.ttf');
    return bytes;
  },
)
""") + """
<p>The loader is called once, lazily, the first time the emoji page opens, so a large colour font does not cost anything on screens that never show emoji.</p>

<h2>Hiding emoji the platform cannot draw</h2>
<p>Newer emoji render as a blank box on older devices. Off by default, because the check costs a measurement pass over the set.</p>
""" + pre("""
VirtualKeypad(
  enableEmojiKey: true,
  checkEmojiPlatformCompatibility: true,
)
""") + """
<p>Worth turning on if your users are on older Android, where the gap between what the picker offers and what the system font has is widest.</p>

<h2>Styling</h2>
""" + pre("""
VirtualKeypad(
  enableEmojiKey: true,
  emojiTextStyle: const TextStyle(fontSize: 28),
)
""") + """
<h2>What the emoji key inserts</h2>
<p>An emoji goes in as text at the cursor, like any other character, so <code>onChanged</code>, validators and length counters all see it. Many emoji are more than one code unit, so count characters with a grapheme-aware method if a length limit matters.</p>
""" + nxt([("languages-and-rtl", "Languages and RTL"), ("theming", "Theming")]),
    faq=[("How do I add an emoji picker to a Flutter keyboard?",
          "Set enableEmojiKey: true. An emoji key appears in the layout and opens an emoji page, with showEmojiKeyboardInitially to open on it directly."),
         ("Why do emoji show as blank boxes on Flutter web?",
          "Flutter downloads an emoji font on demand, so a first offline load has none. This package bundles a subset font and applies it on web to avoid that."),
         ("Can I use colour emoji on web?",
          "Yes. Pass colorEmojiFontLoader returning the font bytes. It is called lazily the first time the emoji page opens.")],
))
print("defined emoji")

# ---------------------------------------------------------------- trouble
PAGES.append(dict(
    slug="troubleshooting",
    title="Flutter Virtual Keyboard Problems and How to Fix Them",
    desc="Fixes for a Flutter on-screen keyboard that does not appear, types into the wrong field, shows the system keyboard as well, or renders blank emoji.",
    h1="Troubleshooting",
    lede="The failures that come up most, and what each one usually turns out to be.",
    body=INSTALL + """
<h2>Both keyboards appear</h2>
<p>The system keyboard opens alongside the on-screen one. Almost always a missing <code>standalone: true</code>: without it the keypad does not take over the field, so the platform opens its own.</p>
""" + pre("""
VirtualKeypad(standalone: true)
""") + """
<p>Do not reach for <code>readOnly: true</code> to silence the system keyboard. It works, and it also removes the caret and text selection, which users notice.</p>

<h2>Nothing types</h2>
<p>Check in this order. No field is focused, so there is nowhere to type. Or the keypad is in scope mode without a <code>VirtualKeypadScope</code> above it. Or a plain <code>TextField</code> is being used in scope mode, where <code>VirtualKeypadTextField</code> is required.</p>
""" + pre("""
VirtualKeypadScope(
  child: Column(
    children: [
      VirtualKeypadTextField(controller: controller),
      const VirtualKeypad(),
    ],
  ),
)
""") + """
<h2>The keyboard is invisible or has no height</h2>
<p>A keyboard inside an unbounded parent gets no height to lay out in. A <code>Column</code> inside a <code>SingleChildScrollView</code> is the usual source. Give it a bounded box or put it outside the scroll view.</p>

<h2>Keys are cut off at the sides</h2>
<p>The keyboard fills the width it is given, so a narrow parent squeezes the keys. Set <code>width</code> explicitly, or use <a href="/floating-keyboard">the floating panel</a> with <code>maxWidth</code>, which was made for this.</p>

<h2>Switching language does nothing</h2>
<p><code>initializeKeyboardLayouts()</code> was never called, so only English is registered and every switch resolves back to it. Call it once at startup, before the keyboard is built.</p>
""" + pre("""
void main() {
  initializeKeyboardLayouts();
  runApp(const MyApp());
}
""") + """
<h2>The language picker never opens</h2>
<p>It opens on a long press of the space bar, and only when <code>availableLanguages</code> holds more than one code. With one entry there is nothing to pick.</p>

<h2>Emoji are blank boxes</h2>
<p>On web, a first offline load has no emoji font yet. The package bundles a subset font for exactly that, so if you are still seeing boxes the font asset is likely missing from the build. On older Android some emoji genuinely have no glyph; <code>checkEmojiPlatformCompatibility: true</code> hides those instead of showing boxes.</p>

<h2>A custom layout throws on build</h2>
<p><code>customLayout</code> and <code>type: KeyboardType.custom</code> must be used together. Each without the other asserts in debug on purpose, so the mistake surfaces at build time rather than as an empty keyboard.</p>

<h2>The D-pad moves app focus instead of the highlight</h2>
<p><code>enableDpadNavigation: true</code> is missing. Note also that an arrow at the edge of the grid is deliberately left unhandled so focus can leave the keyboard, and that space does not press a key, so a paired Bluetooth keyboard still types spaces.</p>

<h2>Keys click twice, or not at all</h2>
<p>Feedback is driven by the <code>feedback</code> parameter, not by Material's ink response, so a press is confirmed the same way whether it came from a tap or a D-pad. <code>KeyFeedback.sound</code> is the default; use <code>none</code> for silence or <code>both</code> to add a vibration.</p>
""" + pre("""
VirtualKeypad(feedback: KeyFeedback.none)
""") + """
<h2>Something else</h2>
<p>The <a href="https://github.com/almasumdev/virtual_keypad/issues">issue tracker</a> is the place. The platform, the mode you are using, and the smallest snippet that reproduces it are what make a report actionable.</p>
""" + nxt([("standalone-mode", "Use any TextField"), ("custom-layouts", "Custom layouts")]),
    faq=[("Why does the system keyboard still open in Flutter?",
          "The keypad is probably missing standalone: true, so it never takes over the field. Avoid readOnly, which also removes the caret and selection."),
         ("Why does my virtual keyboard have no height?",
          "It is inside an unbounded parent, usually a Column in a SingleChildScrollView. Give it a bounded box or move it outside the scroll view."),
         ("Why does changing the keyboard language do nothing?",
          "initializeKeyboardLayouts was never called, so only English is registered. Call it once at startup before the keyboard is built.")],
))
print("defined troubleshooting")

print("all %d pages defined" % len(PAGES))


# ---------------------------------------------------------------- emit

slugs = []
for p in PAGES:
    html = page(p["slug"], p["title"], p["desc"], p["h1"], p["lede"], p["body"], p.get("faq"))
    io.open(os.path.join(OUT, p["slug"] + ".html"), "w", encoding="utf-8", newline="\n").write(html)
    slugs.append(p["slug"])
    print("  %-24s %6d bytes" % (p["slug"] + ".html", len(html)))

urls = "".join(
    "  <url><loc>%s</loc><changefreq>monthly</changefreq><priority>%s</priority></url>\n"
    % (BASE + "/" + ("" if s == "index" else s), "1.0" if s == "index" else "0.8")
    for s in slugs
)
io.open(os.path.join(OUT, "sitemap.xml"), "w", encoding="utf-8", newline="\n").write(
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n%s</urlset>\n' % urls)

io.open(os.path.join(OUT, "robots.txt"), "w", encoding="utf-8", newline="\n").write(
    "User-agent: *\nAllow: /\n\nSitemap: %s/sitemap.xml\n" % BASE)

shutil.copyfile("images/logo.svg", os.path.join(OUT, "logo.svg"))

# Search Console ownership proof. Copied verbatim; Google matches the exact
# bytes at the exact path, so this must not be templated or minified.
for proof in glob.glob("tool/docs_assets/google*.html"):
    shutil.copyfile(proof, os.path.join(OUT, os.path.basename(proof)))

# IndexNow ownership proof: the file name is the key and so are its contents.
io.open(os.path.join(OUT, INDEXNOW_KEY + ".txt"), "w", encoding="utf-8",
        newline="\n").write(INDEXNOW_KEY + "\n")

# Keep firebase.json's clean-URL rewrites in step with the pages that exist.
# These were hand-maintained, so a new page could ship and then 404 in
# production because nobody remembered to add its rewrite.
def _sync_firebase_rewrites(page_slugs):
    fb_path = "firebase.json"
    if not os.path.exists(fb_path):
        return
    conf = json.load(io.open(fb_path, encoding="utf-8"))
    hosting = conf.get("hosting")
    targets = hosting if isinstance(hosting, list) else [hosting]
    # Match on the output directory, not on position: a repo may also host
    # an example web app, and that target has its own single rewrite.
    docs = [t for t in targets if t and t.get("public") == OUT]
    if len(docs) != 1:
        print("firebase.json: no single hosting target for %r, skipped" % OUT)
        return
    target = docs[0]
    wanted = [
        {"source": "/" + p, "destination": "/" + p + ".html"}
        for p in page_slugs if p != "index"
    ]
    if target.get("rewrites") == wanted:
        print("firebase.json rewrites already current (%d)" % len(wanted))
        return
    target["rewrites"] = wanted
    io.open(fb_path, "w", encoding="utf-8", newline="\n").write(
        json.dumps(conf, indent=2, ensure_ascii=False) + '\n'
    )
    print("firebase.json rewrites synced (%d)" % len(wanted))


_sync_firebase_rewrites(slugs)

print("wrote sitemap.xml (%d urls), robots.txt, logo.svg" % len(slugs))
