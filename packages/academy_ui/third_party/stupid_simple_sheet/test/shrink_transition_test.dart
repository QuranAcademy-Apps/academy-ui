import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_simple_sheet/src/shrink_transition.dart';

void main() {
  testWidgets('shrinks a lazy list while preserving its fixed footer', (
    tester,
  ) async {
    final factor = ValueNotifier(0.5);
    final footerHeight = ValueNotifier(64.0);
    addTearDown(factor.dispose);
    addTearDown(footerHeight.dispose);
    var builtItems = 0;
    const footerKey = Key('footer');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 400,
            child: Align(
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder(
                valueListenable: factor,
                builder: (context, value, child) =>
                    ShrinkTransition(sizeFactor: value, child: child),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: 1000,
                        itemExtent: 40,
                        itemBuilder: (context, index) {
                          builtItems += 1;
                          return const SizedBox(height: 40);
                        },
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: footerHeight,
                      builder: (context, height, child) =>
                          SizedBox(key: footerKey, height: height),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final render = tester.renderObject<RenderShrinkTransition>(
      find.byType(ShrinkTransition),
    );
    expect(render.referenceHeight, 400);
    expect(render.size.height, 200);
    expect(render.child!.size.height, 200);
    expect(tester.getSize(find.byKey(footerKey)).height, 64);
    expect(tester.takeException(), isNull);

    factor.value = 0.1;
    await tester.pump();
    expect(render.size.height, 40);
    expect(render.child!.size.height, 64);
    expect(tester.takeException(), isNull);

    footerHeight.value = 96;
    await tester.pump();
    expect(render.size.height, 40);
    expect(render.child!.size.height, 96);
    expect(tester.getSize(find.byKey(footerKey)).height, 96);
    expect(tester.takeException(), isNull);
    expect(builtItems, lessThan(1000));
    expect(RenderObject.debugCheckingIntrinsics, isFalse);

    factor.value = 1;
    await tester.pump();
    expect(render.child!.size.height, 400);
    expect(tester.takeException(), isNull);
  });

  test('restores the intrinsic-checking flag when content throws', () {
    final render = RenderShrinkTransition(sizeFactor: 0.5)
      ..child = _ThrowingIntrinsicBox();
    addTearDown(render.dispose);
    final errors = <FlutterErrorDetails>[];
    final originalHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      render.layout(const BoxConstraints(maxWidth: 300, maxHeight: 400));
      expect(errors, hasLength(1));
      expect(errors.single.exception, isA<StateError>());
      expect(RenderObject.debugCheckingIntrinsics, isFalse);
    } finally {
      FlutterError.onError = originalHandler;
    }
  });
}

class _ThrowingIntrinsicBox extends RenderBox {
  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    throw StateError('Content intrinsic failure');
  }
}
