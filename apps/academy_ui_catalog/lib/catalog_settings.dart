import 'dart:convert';

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sandbox overrides; never changes library defaults or client applications.
class CatalogSettings extends ChangeNotifier {
  CatalogSettings({this.persist = false}) {
    ready = persist ? _restore() : Future.value();
  }
  CatalogSettings.fromJson(Map<String, dynamic> data) : persist = false {
    ready = Future.value();
    _read(data);
  }
  final bool persist;
  bool _edited = false;
  late final Future<void> ready;
  final _radii = <AcademyRadiusRole, double>{};
  final _paddings = <AcademyPaddingRole, EdgeInsets>{};
  final _fonts = <AcademyTextRole, TextStyle>{};
  final _colors = <Brightness, Map<AcademyColorRole, Color>>{};
  static const _key = 'academy_ui.catalog.settings.v1';
  String? error;
  bool _disposed = false;
  Future<void> _writes = Future.value();
  Future<void> get saved => _writes;

  AcademyRadii get radii {
    var result = const AcademyRadii();
    for (final entry in _radii.entries) {
      result = result.withValue(entry.key, entry.value);
    }
    return result;
  }

  AcademyPaddings get paddings {
    var result = const AcademyPaddings();
    for (final entry in _paddings.entries) {
      result = result.withValue(entry.key, entry.value);
    }
    return result;
  }

  AcademyTypographySettings get typography =>
      AcademyTypographySettings(styles: Map.unmodifiable(_fonts));
  AcademyColors colors(
    Brightness brightness,
    Color accent, {
    AcademyColors? base,
  }) {
    var result = AcademyColorsData.from(
      base ?? academyTheme(brightness, accent: accent).colorScheme,
    );
    for (final entry in (_colors[brightness] ?? {}).entries) {
      result = result.withValue(entry.key, entry.value);
    }
    return result;
  }

  void setRadius(AcademyRadiusRole role, double value) {
    _radii[role] = value;
    _changed();
  }

  void setPadding(AcademyPaddingRole role, EdgeInsets value) {
    _paddings[role] = value;
    _changed();
  }

  void setFont(AcademyTextRole role, TextStyle value) {
    _fonts[role] = value;
    _changed();
  }

  void setColor(Brightness brightness, AcademyColorRole role, Color value) {
    (_colors[brightness] ??= {})[role] = value;
    _changed();
  }

  void reset() {
    _radii.clear();
    _paddings.clear();
    _fonts.clear();
    _colors.clear();
    _changed();
  }

  Map<String, dynamic> toJson() => {
    'radii': {for (final e in _radii.entries) e.key.name: e.value},
    'paddings': {
      for (final e in _paddings.entries)
        e.key.name: [e.value.left, e.value.top, e.value.right, e.value.bottom],
    },
    'fonts': {
      for (final e in _fonts.entries)
        e.key.name: {
          'size': e.value.fontSize,
          'weight': e.value.fontWeight?.value,
          'height': e.value.height,
        },
    },
    'colors': {
      for (final b in _colors.entries)
        b.key.name: {
          for (final e in b.value.entries) e.key.name: e.value.toARGB32(),
        },
    },
  };
  void _read(Map<String, dynamic> data) {
    for (final e in (data['radii'] as Map<String, dynamic>? ?? {}).entries) {
      _radii[AcademyRadiusRole.values.byName(e.key)] = (e.value as num)
          .toDouble();
    }
    for (final e in (data['paddings'] as Map<String, dynamic>? ?? {}).entries) {
      final v = (e.value as List).cast<num>();
      _paddings[AcademyPaddingRole.values.byName(e.key)] = EdgeInsets.fromLTRB(
        v[0].toDouble(),
        v[1].toDouble(),
        v[2].toDouble(),
        v[3].toDouble(),
      );
    }
    for (final e in (data['fonts'] as Map<String, dynamic>? ?? {}).entries) {
      final v = e.value as Map<String, dynamic>;
      _fonts[AcademyTextRole.values.byName(e.key)] = TextStyle(
        fontSize: (v['size'] as num?)?.toDouble(),
        fontWeight: v['weight'] == null
            ? null
            : FontWeight.values.firstWhere((w) => w.value == v['weight']),
        height: (v['height'] as num?)?.toDouble(),
      );
    }
    for (final b in (data['colors'] as Map<String, dynamic>? ?? {}).entries) {
      _colors[Brightness.values.byName(b.key)] = {
        for (final e in (b.value as Map<String, dynamic>).entries)
          AcademyColorRole.values.byName(e.key): Color(e.value as int),
      };
    }
  }

  Future<void> _restore() async {
    try {
      final raw = await SharedPreferencesAsync().getString(_key);
      if (!_disposed && !_edited && raw != null) {
        _read(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      _radii.clear();
      _paddings.clear();
      _fonts.clear();
      _colors.clear();
      error = 'Не удалось восстановить настройки компонентов';
    }
    if (!_disposed) notifyListeners();
  }

  void _changed() {
    _edited = true;
    error = null;
    notifyListeners();
    if (!persist) return;
    final snapshot = jsonEncode(toJson());
    _writes = _writes.then((_) async {
      try {
        await SharedPreferencesAsync().setString(_key, snapshot);
      } catch (_) {
        error = 'Не удалось сохранить настройки компонентов';
        if (!_disposed) notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
