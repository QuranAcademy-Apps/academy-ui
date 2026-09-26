import 'package:flutter/cupertino.dart';

import 'academy_appearance.dart';
import 'academy_scroll_behavior.dart';
import 'academy_theme.dart';
import 'academy_feedback_extras.dart';
import 'chrome/academy_chrome.dart';

/// Optional host that places the resolved palette and navigation chrome above
/// Navigator, so an open modal follows changes to theme and accent.
class AcademyApp extends StatefulWidget {
  const AcademyApp({
    super.key,
    required this.home,
    this.appearance,
    this.navigatorKey,
    this.title = 'Academy UI',
    this.colorsBuilder,
    this.toastBottomObstruction = 0,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
  });
  final Widget home;
  final AcademyAppearanceController? appearance;
  final GlobalKey<NavigatorState>? navigatorKey;
  final String title;

  /// Optional client palette. Omit to use the design-system defaults.
  final AcademyColorsBuilder? colorsBuilder;
  final double toastBottomObstruction;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  @override
  State<AcademyApp> createState() => _AcademyAppState();
}

class _AcademyAppState extends State<AcademyApp> with WidgetsBindingObserver {
  late AcademyAppearanceController _appearance;
  bool _ownsAppearance = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bind();
  }

  void _bind() {
    _ownsAppearance = widget.appearance == null;
    _appearance = widget.appearance ?? AcademyAppearanceController();
    _appearance.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangePlatformBrightness() => _changed();
  @override
  void didUpdateWidget(AcademyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appearance != widget.appearance) {
      _appearance.removeListener(_changed);
      if (_ownsAppearance) _appearance.dispose();
      _bind();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appearance.removeListener(_changed);
    if (_ownsAppearance) _appearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = _appearance.value;
    final brightness = switch (appearance.mode) {
      AcademyAppearanceMode.light => Brightness.light,
      AcademyAppearanceMode.dark => Brightness.dark,
      AcademyAppearanceMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    final theme = academyTheme(
      brightness,
      accent: appearance.accent,
      colors: widget.colorsBuilder?.call(brightness, appearance.accent),
    );
    return CupertinoApp(
      title: widget.title,
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navigatorKey,
      theme: theme.cupertino,
      localizationsDelegates: widget.localizationsDelegates,
      supportedLocales: widget.supportedLocales,
      scrollBehavior: const AcademyScrollBehavior(),
      builder: (_, child) => AcademyTheme(
        data: theme,
        child: AcademyChromeTheme(
          style: appearance.chromeStyle,
          blurSigma: appearance.blurSigma,
          tabBarDensity: appearance.tabBarDensity,
          child: AcademyToastHost(
            bottomObstruction: widget.toastBottomObstruction,
            child: child!,
          ),
        ),
      ),
      home: widget.home,
    );
  }
}
