import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const options = [
  AcademySelectOption(value: 'reading', label: 'Чтение'),
  AcademySelectOption(value: 'audio', label: 'Аудио'),
  AcademySelectOption(value: 'soon', label: 'Скоро', enabled: false),
];

Widget host(Widget child) => AcademyApp(
  home: CupertinoPageScaffold(
    child: Center(child: SizedBox(width: 320, child: child)),
  ),
);

void main() {
  testWidgets('menu selects an enabled value without opening a modal', (
    tester,
  ) async {
    String? value;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, update) => AcademySelect<String>(
            label: 'Язык',
            value: value,
            options: options,
            presentation: AcademySelectPresentation.menu,
            onChanged: (next) => update(() => value = next),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();
    expect(find.byType(AcademyMenuItem), findsNWidgets(3));
    expect(find.byType(AcademyTextInput), findsNothing);
    expect(
      tester
          .widget<AcademyMenuItem>(
            find.widgetWithText(AcademyMenuItem, 'Скоро'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Аудио'));
    await tester.pumpAndSettle();
    expect(value, 'audio');
    expect(find.byType(AcademyMenuItem), findsNothing);
    await tester.tap(find.text('Аудио'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AcademyMenuItem), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'topic menu updates checkmarks and keeps multiple selection open',
    (tester) async {
      Set<String> values = {'reading'};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, update) => AcademyMultiSelect<String>(
              label: 'Темы',
              values: values,
              options: options,
              presentation: AcademySelectPresentation.menu,
              onChanged: (next) => update(() => values = next),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Выбрано: 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AcademyMenuItem, 'Аудио'));
      await tester.pumpAndSettle();
      expect(values, {'reading', 'audio'});
      expect(() => values.add('soon'), throwsUnsupportedError);
      expect(
        tester
            .widget<AcademyMenuItem>(
              find.widgetWithText(AcademyMenuItem, 'Аудио'),
            )
            .checked,
        isTrue,
      );
      await tester.tap(find.widgetWithText(AcademyMenuItem, 'Чтение'));
      await tester.pumpAndSettle();
      expect(values, {'audio'});
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AcademyMenuItem), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
