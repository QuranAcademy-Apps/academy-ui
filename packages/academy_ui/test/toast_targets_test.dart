import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  Widget overlay(
    String? message, {
    VoidCallback? onAction,
    VoidCallback? onDismissed,
    bool showCloseButton = false,
    AcademyInteractionTheme interaction = const AcademyInteractionTheme(),
  }) => academyHost(
    AcademyToastOverlay(
      message: message,
      position: AcademyToastPosition.top,
      actionLabel: onAction == null ? null : 'Вернуть',
      onAction: onAction,
      onDismissed: onDismissed,
      showCloseButton: showCloseButton,
    ),
    interaction: interaction,
  );

  testWidgets('close and action are named 44pt buttons', (tester) async {
    final handle = tester.ensureSemantics();
    var closed = 0, acted = 0;
    await tester.pumpWidget(
      overlay(
        'Удалено',
        showCloseButton: true,
        onDismissed: () => closed++,
        onAction: () => acted++,
      ),
    );
    await tester.pumpAndSettle();
    final buttons = find.byType(CupertinoButton);
    expect(buttons, findsNWidgets(2));
    for (final button in buttons.evaluate()) {
      final size = (button.renderObject! as RenderBox).size;
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }
    expect(find.bySemanticsLabel('Закрыть'), findsOneWidget);
    expect(find.bySemanticsLabel('Вернуть'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Вернуть'));
    await tester.pumpAndSettle();
    expect((closed, acted), (0, 1));
    handle.dispose();
  });

  testWidgets('a label without an action leaves the normal end inset', (
    tester,
  ) async {
    await tester.pumpWidget(
      academyHost(
        const AcademyToastOverlay(
          message: 'Сохранено',
          position: AcademyToastPosition.top,
          actionLabel: 'Вернуть',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Вернуть'), findsNothing);
    final padding = tester.widget<Padding>(
      find
          .ancestor(
            of: find.byType(AcademyToastContent),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(
      padding.padding.resolve(TextDirection.ltr),
      const EdgeInsets.only(left: 20, right: 20),
    );
  });

  testWidgets('a plain toast keeps its height', (tester) async {
    await tester.pumpWidget(overlay('Сохранено'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AcademyToastContent)).height,
      greaterThanOrEqualTo(tester.getSize(find.text('Сохранено')).height + 24),
    );
  });

  testWidgets('the same message shown again is announced again', (
    tester,
  ) async {
    var announcements = 0, clicks = 0;
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        if ((message as Map)['type'] == 'announce') announcements++;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility,
            null,
          ),
    );
    final interaction = AcademyInteractionTheme(
      selectionFeedback: () => clicks++,
    );
    await tester.pumpWidget(overlay('Готово', interaction: interaction));
    await tester.pumpAndSettle();
    expect((announcements, clicks), (1, 1));
    await tester.pumpWidget(overlay(null, interaction: interaction));
    await tester.pumpAndSettle();
    await tester.pumpWidget(overlay('Готово', interaction: interaction));
    await tester.pumpAndSettle();
    expect((announcements, clicks), (2, 2));
  });

  testWidgets('the keyboard covers the obstruction instead of adding to it', (
    tester,
  ) async {
    phone(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    late BuildContext context;
    await tester.pumpWidget(
      AcademyApp(
        toastBottomObstruction: 83,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    AcademyToastHost.show(
      context,
      'Сообщение',
      position: AcademyToastPosition.bottom,
    );
    await tester.pumpAndSettle();
    final toast = tester.getRect(find.byKey(const ValueKey('academy-toast')));
    expect(toast.bottom, 844 - 300 - 8);
  });
}
