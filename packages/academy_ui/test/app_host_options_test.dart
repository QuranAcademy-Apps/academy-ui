import 'dart:async';

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  testWidgets('AcademyApp passes every theme value on', (tester) async {
    const switchColor = Color(0xFF00FF00);
    const checkmarkColor = Color(0xFF0000FF);
    const loading = SizedBox(key: ValueKey('loading'));
    late BuildContext context;
    await tester.pumpWidget(
      AcademyApp(
        switchColor: switchColor,
        checkmarkColor: checkmarkColor,
        feedbackLoadingIndicator: loading,
        reduceTransparency: true,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final theme = AcademyTheme.of(context);
    expect(theme.switchColor, switchColor);
    expect(theme.checkmarkColor, checkmarkColor);
    expect(theme.feedbackLoadingIndicator, loading);
    expect(AcademyChromeTheme.maybeOf(context)?.reduceTransparency, isTrue);
  });

  testWidgets('Reduce Motion jumps to the top instead of animating', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      CupertinoApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: AcademyScrollToTop(
              controller: controller,
              child: ListView.builder(
                controller: controller,
                itemExtent: 80,
                itemCount: 100,
                itemBuilder: (_, index) => Text('$index'),
              ),
            ),
          ),
        ),
      ),
    );
    controller.jumpTo(600);
    final response = Completer<void>();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'flutter/status_bar',
          const JSONMethodCodec().encodeMethodCall(
            const MethodCall('handleScrollToTop'),
          ),
          (_) => response.complete(),
        );
    await response.future;
    expect(controller.offset, 0);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('the photo viewer close button follows the direction', (
    tester,
  ) async {
    phone(tester);
    late BuildContext context;
    await tester.pumpWidget(
      AcademyApp(
        locale: const Locale('ar'),
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    unawaited(
      showAcademyPhotoViewer(
        context,
        itemCount: 1,
        itemBuilder: (_, _) => const Text('Фото'),
      ),
    );
    await tester.pumpAndSettle();
    final close = tester.getCenter(
      find.byKey(const ValueKey('photo-viewer-close')),
    );
    expect(close.dx, lessThan(195));
  });
}
