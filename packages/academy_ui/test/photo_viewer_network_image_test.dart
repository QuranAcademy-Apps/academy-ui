import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// Photo viewer and network image ported from Yalla (2026-11-02). Their pixels
// are checked against Yalla's originals in yalla-app/test/parity.

const _fallback = ColoredBox(
  key: ValueKey('fallback'),
  color: Color(0xFF3A6EA5),
);

Future<Uint8List> _png() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 4, 4),
    Paint()..color = const Color(0xFF00AA00),
  );
  final image = await recorder.endRecording().toImage(4, 4);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  testWidgets('network image accepts only plain HTTPS URLs', (tester) async {
    for (final url in [
      'http://example.com/a.jpg',
      'https://user:secret@example.com/a.jpg',
      'not a url',
      'https:///a.jpg',
    ]) {
      await tester.pumpWidget(
        AcademyApp(
          home: AcademyNetworkImage(url: url, fallback: _fallback),
        ),
      );
      expect(
        find.byKey(const ValueKey('fallback')),
        findsOneWidget,
        reason: url,
      );
      expect(find.byType(Image), findsNothing, reason: url);
    }
  });

  testWidgets('network image loads through the client provider', (
    tester,
  ) async {
    final requested = <String>[];
    final png = (await tester.runAsync(_png))!;
    await tester.pumpWidget(
      AcademyApp(
        home: AcademyNetworkImage(
          url: 'https://example.com/a.png',
          fallback: _fallback,
          width: 120,
          height: 80,
          provider: (url) {
            requested.add(url);
            return MemoryImage(png);
          },
        ),
      ),
    );
    expect(requested, ['https://example.com/a.png']);
    expect(find.bySemanticsLabel('Загрузка изображения'), findsOneWidget);
    // The skeleton pulses until the frame arrives, so pump instead of settle.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.bySemanticsLabel('Загрузка изображения'), findsNothing);
    expect(find.byKey(const ValueKey('fallback')), findsNothing);
  });

  test('decode width rounds up to shared tiers', () {
    expect(academyPhotoDecodeWidth(390, 3, 1), 1536);
    expect(academyPhotoDecodeWidth(100, 1, 1), 512);
    expect(academyPhotoDecodeWidth(430, 3, 5), 8192);
  });

  testWidgets('photo viewer: localized close action and swipe-down dismissal', (
    tester,
  ) async {
    await tester.pumpWidget(
      AcademyApp(
        home: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => showAcademyPhotoViewer(
              context,
              itemCount: 2,
              itemBuilder: (_, index) => Text('Фото $index'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('academy-photo-viewer')), findsOneWidget);
    expect(find.bySemanticsLabel('Закрыть просмотр фото'), findsOneWidget);

    await tester.drag(find.text('Фото 0'), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('academy-photo-viewer')), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('photo-viewer-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('academy-photo-viewer')), findsNothing);
  });
}
