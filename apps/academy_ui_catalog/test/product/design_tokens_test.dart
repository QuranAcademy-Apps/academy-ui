import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme tokens update buttons, fields, tables and an open sheet', (
    tester,
  ) async {
    final revision = ValueNotifier(false);
    addTearDown(revision.dispose);
    final appearance = AcademyAppearanceController();
    await appearance.ready;
    addTearDown(appearance.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: revision,
        builder: (_, edited, _) => AcademyApp(
          appearance: appearance,
          radii: edited
              ? const AcademyRadii(
                  button: 4,
                  field: 6,
                  table: 8,
                  surface: 10,
                  disclosure: 11,
                  modal: 12,
                )
              : const AcademyRadii(),
          paddings: edited
              ? const AcademyPaddings(
                  button: EdgeInsets.all(18),
                  field: EdgeInsets.all(20),
                  modal: EdgeInsets.all(10),
                  tableRow: EdgeInsets.fromLTRB(25, 7, 31, 9),
                )
              : const AcademyPaddings(),
          typography: edited
              ? const AcademyTypographySettings(
                  fontFamily: 'Inter',
                  displayFontFamily: 'Inter',
                  fontPackage: 'academy_ui',
                  styles: {
                    AcademyTextRole.labelLarge: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  },
                )
              : const AcademyTypographySettings(),
          home: Builder(
            builder: (context) => Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AcademyButton(
                      label: 'Open',
                      onPressed: () => showAcademyModal<void>(
                        context,
                        title: 'Sheet',
                        builder: (_) => AcademyModalListView(
                          children: [
                            AcademyButton(label: 'Inside', onPressed: () {}),
                            const AcademyField(label: 'Sheet field'),
                            const AcademySurface(child: Text('Sheet surface')),
                            AcademyDisclosureCard(
                              title: 'Sheet disclosure',
                              expanded: false,
                              onToggle: () {},
                              child: const Text('Details'),
                            ),
                            const AcademyTableBody(
                              rows: [AcademyRow(title: 'Sheet row')],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const AcademyField(label: 'Field'),
                    const AcademySurface(child: Text('Surface')),
                    AcademyDisclosureCard(
                      title: 'Disclosure',
                      expanded: false,
                      onToggle: () {},
                      child: const Text('Details'),
                    ),
                    const AcademyTableBody(rows: [AcademyRow(title: 'Row')]),
                    const AcademyTableBody(
                      cornerRadius: 3,
                      rows: [AcademyRow(title: 'Override')],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    revision.value = true;
    await tester.pumpAndSettle();
    final sheetButton = find.descendant(
      of: find.widgetWithText(AcademyButton, 'Inside'),
      matching: find.byType(CupertinoButton),
    );
    final button = tester.widget<CupertinoButton>(sheetButton);
    expect(button.borderRadius, BorderRadius.circular(4));
    expect(button.padding, const EdgeInsets.all(18));
    final text = DefaultTextStyle.of(tester.element(find.text('Inside'))).style;
    expect(text.fontSize, 21);
    expect(text.fontFamily, 'packages/academy_ui/Inter');
    final field = tester.widget<CupertinoTextField>(
      find.descendant(
        of: find.widgetWithText(AcademyField, 'Sheet field'),
        matching: find.byType(CupertinoTextField),
      ),
    );
    expect(field.padding, const EdgeInsets.all(20));
    expect(field.decoration!.borderRadius, BorderRadius.circular(6));
    for (final (container, radius) in [
      (find.widgetWithText(AcademySurface, 'Sheet surface'), 10.0),
      (
        find.byWidgetPredicate(
          (w) => w is AcademyDisclosureCard && w.title == 'Sheet disclosure',
        ),
        11.0,
      ),
      (find.widgetWithText(AcademyTableBody, 'Sheet row'), 8.0),
    ]) {
      final fill = tester.widget<ModalSheetMaskedFill>(
        find.descendant(
          of: container,
          matching: find.byType(ModalSheetMaskedFill),
        ),
      );
      expect(fill.borderRadius, BorderRadius.circular(radius));
    }
    final surface = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(ModalSheetRoundedSurface),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final shape =
        (surface.decoration as ShapeDecoration).shape
            as RoundedSuperellipseBorder;
    expect(
      shape.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(12)),
    );
    final list = tester.widget<ListView>(
      find.descendant(
        of: find.byType(AcademyModalListView),
        matching: find.byType(ListView),
      ),
    );
    expect((list.padding! as EdgeInsets).left, 10);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AcademyChromeButton && w.label == 'Закрыть',
      ),
    );
    await tester.pumpAndSettle();
    final cardDecoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(AcademySurface),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as ShapeDecoration;
    expect(
      (cardDecoration.shape as RoundedSuperellipseBorder).borderRadius,
      BorderRadius.circular(10),
    );
    final disclosureFill = tester.widget<ModalSheetMaskedFill>(
      find.descendant(
        of: find.byType(AcademyDisclosureCard),
        matching: find.byType(ModalSheetMaskedFill),
      ),
    );
    expect(disclosureFill.borderRadius, BorderRadius.circular(11));
    final boxes = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(AcademyTableBody),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>();
    expect(
      boxes.any((box) => box.borderRadius == BorderRadius.circular(8)),
      isTrue,
    );
    expect(
      boxes.any((box) => box.borderRadius == BorderRadius.circular(3)),
      isTrue,
    );
    final rowPadding = tester.widget<Padding>(
      find
          .descendant(
            of: find.widgetWithText(AcademyRow, 'Row'),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(
      rowPadding.padding.resolve(TextDirection.ltr),
      const EdgeInsets.fromLTRB(25, 7, 31, 9),
    );
    expect(tester.takeException(), isNull);
  });
}
