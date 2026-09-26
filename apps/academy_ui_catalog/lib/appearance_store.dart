import 'dart:convert';

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesAppearanceStore implements AcademyAppearanceStore {
  final _preferences = SharedPreferencesAsync();
  static const _key = 'academy_ui.example.appearance.v1';
  @override
  Future<AcademyAppearance?> read() async {
    final saved = await _preferences.getString(_key);
    if (saved == null) return null;
    final data = jsonDecode(saved) as Map<String, dynamic>;
    return AcademyAppearance(
      mode: AcademyAppearanceMode.values.byName(data['mode'] as String),
      accent: Color(data['accent'] as int),
      chromeStyle: AcademyChromeStyle.values.byName(data['chrome'] as String),
      tabBarDensity: AcademyTabBarDensity.values.byName(
        data['tabBarDensity'] as String? ?? 'standard',
      ),
    );
  }

  @override
  Future<void> write(AcademyAppearance appearance) => _preferences.setString(
    _key,
    jsonEncode({
      'mode': appearance.mode.name,
      'accent': appearance.accent.toARGB32(),
      'chrome': appearance.chromeStyle.name,
      'tabBarDensity': appearance.tabBarDensity.name,
    }),
  );
}
