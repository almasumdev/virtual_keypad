/// The accented letters offered when a Latin key is held down.
///
/// Every mobile keyboard hides its accents behind a long press rather than on
/// a separate page, because a French or Polish word needs one mid-sentence.
/// Keys are lowercase; the uppercase forms are derived when shift is on, so
/// only one table is maintained.
///
/// Pass your own map to `VirtualKeypad.accents` to change or extend this, or
/// an empty map to turn the popup off.
///
/// {@category Layouts}
const Map<String, List<String>> kLatinAccents = {
  'a': ['à', 'á', 'â', 'ä', 'ã', 'å', 'ą', 'æ'],
  'c': ['ç', 'ć', 'č'],
  'd': ['ď', 'đ'],
  'e': ['è', 'é', 'ê', 'ë', 'ę', 'ě'],
  'g': ['ğ'],
  'i': ['ì', 'í', 'î', 'ï', 'ı'],
  'l': ['ł'],
  'n': ['ñ', 'ń', 'ň'],
  'o': ['ò', 'ó', 'ô', 'ö', 'õ', 'ø', 'œ'],
  'r': ['ř'],
  's': ['ß', 'ś', 'š', 'ş'],
  't': ['ť'],
  'u': ['ù', 'ú', 'û', 'ü', 'ů'],
  'y': ['ý', 'ÿ'],
  'z': ['ź', 'ż', 'ž'],
};
