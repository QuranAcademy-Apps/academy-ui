import 'package:flutter/cupertino.dart';

import 'academy_theme.dart';
import 'chrome/academy_chrome.dart';

@immutable
class AcademyAppearance {
  const AcademyAppearance({
    this.mode = AcademyAppearanceMode.system,
    this.accent = AcademyTokens.brand,
    this.chromeStyle = AcademyChromeStyle.flat,
    this.tabBarDensity = AcademyTabBarDensity.standard,
  });
  final AcademyAppearanceMode mode;
  final Color accent;
  final AcademyChromeStyle chromeStyle;
  final AcademyTabBarDensity tabBarDensity;
  double get blurSigma => 20;

  AcademyAppearance copyWith({
    AcademyAppearanceMode? mode,
    Color? accent,
    AcademyChromeStyle? chromeStyle,
    AcademyTabBarDensity? tabBarDensity,
  }) => AcademyAppearance(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    chromeStyle: chromeStyle ?? this.chromeStyle,
    tabBarDensity: tabBarDensity ?? this.tabBarDensity,
  );
}

/// Persistence is supplied by the consuming app; no hidden preferences service.
abstract interface class AcademyAppearanceStore {
  Future<AcademyAppearance?> read();
  Future<void> write(AcademyAppearance appearance);
}

class AcademyAppearanceController extends ChangeNotifier {
  AcademyAppearanceController({
    AcademyAppearance initial = const AcademyAppearance(),
    AcademyAppearanceStore? store,
  }) : _value = initial,
       // Public parameter name intentionally differs from private storage.
       // ignore: prefer_initializing_formals
       _store = store {
    ready = _load();
  }
  AcademyAppearance _value;
  final AcademyAppearanceStore? _store;
  bool _disposed = false;
  bool _loading = true;
  Object? _persistenceError;
  Future<void> _saveTail = Future.value();
  late final Future<void> ready;

  AcademyAppearance get value => _value;
  bool get isLoading => _loading;
  Object? get persistenceError => _persistenceError;
  Future<void> get flushed => _saveTail;

  Future<void> _load() async {
    try {
      final saved = await _store?.read();
      if (!_disposed && saved != null) _value = saved;
    } catch (error) {
      if (!_disposed) _persistenceError = error;
    } finally {
      _loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// UI disables controls during loading; late restoration cannot overwrite edits.
  void update(AcademyAppearance appearance) {
    if (_disposed || _loading) return;
    _value = appearance;
    _persistenceError = null;
    notifyListeners();
    final store = _store;
    if (store == null) return;
    _saveTail = _saveTail.then((_) async {
      try {
        await store.write(appearance);
      } catch (error) {
        if (!_disposed) {
          _persistenceError = error;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
