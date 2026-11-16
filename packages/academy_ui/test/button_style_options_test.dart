import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('button styles are regular (flat) and glass', () {
    expect(AcademyChromeStyle.buttonStyles, [
      AcademyChromeStyle.flat,
      AcademyChromeStyle.glass,
    ]);
  });

  test('button style labels', () {
    const ru = AcademyLocalizations(Locale('ru'));
    expect(ru.buttonStyle('flat'), 'Обычные');
    expect(ru.buttonStyle('glass'), 'Стекло');
  });
}
