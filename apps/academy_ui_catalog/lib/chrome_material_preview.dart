import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

/// A moving backdrop makes the neutral navigation material easy to inspect.
class ChromeMaterialPreview extends StatelessWidget {
  const ChromeMaterialPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final colors = dark
        ? const [Color(0xFF153A58), Color(0xFF4B2948), Color(0xFF204437)]
        : const [Color(0xFFB8DCFF), Color(0xFFF5CEE8), Color(0xFFBCE7D2)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radii.surface),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.only(top: 64, bottom: 72),
                children: [
                  for (var i = 0; i < 8; i++)
                    ColoredBox(
                      color: colors[i % colors.length],
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          i == 0
                              ? 'Прокрутите фон под панелями'
                              : 'Содержимое $i',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: AcademyChromeCapsule(
                style: AcademyChromeStyle.blur,
                child: Center(
                  child: Text('Навигация', style: theme.textTheme.titleMedium),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              child: AcademyChromeGroup(
                style: AcademyChromeStyle.blur,
                actions: [
                  AcademyChromeAction(
                    AcademySymbols.book,
                    'Книга',
                    () => AcademyToastHost.show(context, 'Книга'),
                  ),
                  AcademyChromeAction(
                    AcademySymbols.search,
                    'Поиск',
                    () => AcademyToastHost.show(context, 'Поиск'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
