import '../theme/academy_row_icons.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../foundation/localizations/academy_localizations.dart';

import 'academy_appearance.dart';
import '../foundation/scroll/academy_scroll_behavior.dart';
import '../theme/academy_theme.dart';
import '../widgets/toast/academy_toast.dart';
import '../widgets/navigation/chrome/academy_chrome.dart';

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
    this.radii = const AcademyRadii(),
    this.paddings = const AcademyPaddings(),
    this.typography = const AcademyTypographySettings(),
    this.interaction = const AcademyInteractionTheme(),
    this.icons = const AcademyIcons(),
    this.rowIconColors = const {},
    this.chromeColors = const AcademyChromeColors(),
    this.toastBottomObstruction = 0,
    double? chromeBlurToneStrength,
    double? chromeBlurTintOpacity,
    this.localizationsDelegates,
    this.supportedLocales = AcademyLocalizations.supportedLocales,
    this.locale = const Locale('ru'),
  }) : chromeBlurToneStrength =
           chromeBlurToneStrength ??
           chromeBlurTintOpacity ??
           AcademyTokens.chromeBlurToneStrength,
       assert(
         chromeBlurToneStrength == null ||
             chromeBlurToneStrength >= 0 && chromeBlurToneStrength <= 1,
       ),
       assert(
         chromeBlurTintOpacity == null ||
             chromeBlurTintOpacity >= 0 && chromeBlurTintOpacity <= 1,
       );
  final Widget home;
  final AcademyAppearanceController? appearance;
  final GlobalKey<NavigatorState>? navigatorKey;
  final String title;

  /// Optional client palette. Omit to use the design-system defaults.
  final AcademyColorsBuilder? colorsBuilder;
  final AcademyRadii radii;
  final AcademyPaddings paddings;
  final AcademyTypographySettings typography;
  final AcademyInteractionTheme interaction;

  /// Glyphs the library draws on its own.
  final AcademyIcons icons;
  final Map<AcademyRowIcons, Color> rowIconColors;
  final AcademyChromeColors chromeColors;
  final double toastBottomObstruction;
  final double chromeBlurToneStrength;

  /// Compatibility alias: controls the filtered backdrop, not overlay opacity.
  double get chromeBlurTintOpacity => chromeBlurToneStrength;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;

  /// Set null to follow the device locale.
  final Locale? locale;
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
      radii: widget.radii,
      paddings: widget.paddings,
      typography: widget.typography,
      interaction: widget.interaction,
      icons: widget.icons,
      rowIconColors: widget.rowIconColors,
      chromeColors: widget.chromeColors,
      colors: widget.colorsBuilder?.call(brightness, appearance.accent),
    );
    return CupertinoApp(
      title: widget.title,
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navigatorKey,
      theme: theme.cupertino,
      locale: widget.locale,
      localizationsDelegates: [
        ...?widget.localizationsDelegates,
        AcademyLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: widget.supportedLocales,
      scrollBehavior: const AcademyScrollBehavior(),
      builder: (_, child) => AcademyTheme(
        data: theme,
        child: AcademyChromeTheme(
          style: appearance.chromeStyle,
          blurSigma: appearance.blurSigma,
          blurToneStrength: widget.chromeBlurToneStrength,
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
