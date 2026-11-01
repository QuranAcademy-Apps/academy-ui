import 'package:flutter/widgets.dart';

/// Strings the moved Quran widgets need from the host app (accessibility labels).
/// Provide them with [QuranCompatStringsDelegate] in the app's localization
/// delegates; without it the English defaults are used.
class QuranCompatStrings {
  const QuranCompatStrings({
    this.close = 'Close',
    this.dragHandle = 'Drag handle',
  });

  final String close;
  final String dragHandle;

  static QuranCompatStrings of(BuildContext context) =>
      Localizations.of<QuranCompatStrings>(context, QuranCompatStrings) ??
      const QuranCompatStrings();
}

class QuranCompatStringsDelegate
    extends LocalizationsDelegate<QuranCompatStrings> {
  const QuranCompatStringsDelegate(this.loader);

  final Future<QuranCompatStrings> Function(Locale locale) loader;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<QuranCompatStrings> load(Locale locale) => loader(locale);

  @override
  bool shouldReload(QuranCompatStringsDelegate old) => false;
}
