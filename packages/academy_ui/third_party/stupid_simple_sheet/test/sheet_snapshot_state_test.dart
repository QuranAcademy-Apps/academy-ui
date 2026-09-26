import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_simple_sheet/src/route_snapshot_mode.dart';
import 'package:stupid_simple_sheet/src/sheet_snapshot_state.dart';

void main() {
  testWidgets('scroll freeze settles and stays frozen under a child sheet',
      (tester) async {
    final animation = AnimationController(vsync: const TestVSync(), value: 1);
    var covered = false;
    late SheetSnapshotState snapshot;
    void update() => snapshot.update(
          mode: RouteSnapshotMode.animatingAndScrolling,
          animation: animation,
          isUserDragging: false,
          maxExtent: 1,
          animationTargetValue: 1,
          isCovered: covered,
        );
    snapshot = SheetSnapshotState(onScrollChanged: update);
    addTearDown(snapshot.dispose);
    addTearDown(animation.dispose);
    late BuildContext context;
    await tester.pumpWidget(Builder(builder: (value) {
      context = value;
      return const SizedBox();
    }));
    final metrics = FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 100,
      pixels: 0,
      viewportDimension: 100,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    );
    update();
    expect(snapshot.controller.allowSnapshotting, isFalse);
    expect(
      snapshot.handleContentScroll(
        ScrollStartNotification(metrics: metrics, context: context),
      ),
      isFalse,
    );
    expect(snapshot.controller.allowSnapshotting, isTrue);
    await tester.pump(const Duration(milliseconds: 119));
    expect(snapshot.controller.allowSnapshotting, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    expect(snapshot.controller.allowSnapshotting, isFalse);

    snapshot.handleContentScroll(
      ScrollUpdateNotification(metrics: metrics, context: context),
    );
    covered = true;
    await tester.pump(const Duration(milliseconds: 120));
    expect(snapshot.contentScrolling, isFalse);
    expect(snapshot.controller.allowSnapshotting, isTrue);
    covered = false;
    update();
    expect(snapshot.controller.allowSnapshotting, isFalse);
  });

  test('snapshot modes preserve settled, dragging and disabled behavior', () {
    final animation = AnimationController(vsync: const TestVSync(), value: 1);
    final snapshot = SheetSnapshotState(onScrollChanged: () {});
    addTearDown(animation.dispose);
    addTearDown(snapshot.dispose);

    void check(RouteSnapshotMode mode, bool expected, {bool dragging = false}) {
      snapshot.update(
        mode: mode,
        animation: animation,
        isUserDragging: dragging,
        maxExtent: 1,
        animationTargetValue: 1,
        isCovered: false,
      );
      expect(snapshot.controller.allowSnapshotting, expected, reason: '$mode');
    }

    check(RouteSnapshotMode.never, false, dragging: true);
    check(RouteSnapshotMode.always, true);
    check(RouteSnapshotMode.animating, false);
    check(RouteSnapshotMode.animating, true, dragging: true);
    check(RouteSnapshotMode.settled, true);
    check(RouteSnapshotMode.settled, false, dragging: true);
    check(RouteSnapshotMode.openAndForward, true);
    check(RouteSnapshotMode.openAndForward, false, dragging: true);
  });
}
