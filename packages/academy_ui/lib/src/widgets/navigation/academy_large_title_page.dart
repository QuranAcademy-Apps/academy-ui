import 'package:flutter/cupertino.dart';

import '../../foundation/layout/academy_page_insets.dart';
import '../../foundation/layout/academy_text_fit.dart';
import '../../theme/academy_theme.dart';
import 'academy_page.dart';
import 'chrome/academy_chrome_metrics.dart';
import 'chrome/academy_tabs.dart';

// Ported from Yalla's yalla_large_title_page.dart (2026-11-02).
/// A large heading hands off to the navbar without changing list geometry.
class AcademyLargeTitlePage extends StatefulWidget {
  const AcademyLargeTitlePage({
    super.key,
    required this.title,
    required this.children,
    this.heading,
    this.eyebrow,
    this.headingStyle,
    this.titleGap = 16,
    this.horizontalPadding = 20,
    this.tab = false,
    this.scrollKey,
  });

  final String title;
  final String? heading, eyebrow;
  final TextStyle? headingStyle;
  final List<Widget> children;
  final double titleGap, horizontalPadding;
  final bool tab;
  final Key? scrollKey;

  @override
  State<AcademyLargeTitlePage> createState() => _AcademyLargeTitlePageState();
}

class _AcademyLargeTitlePageState extends State<AcademyLargeTitlePage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final theme = AcademyTheme.of(context);
      final style = widget.headingStyle ?? theme.textTheme.displaySmall;
      final width =
          constraints.maxWidth.clamp(40, 430) - widget.horizontalPadding * 2;
      double textHeight(String text, TextStyle style, [TextScaler? scaler]) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: scaler ?? MediaQuery.textScalerOf(context),
        )..layout(maxWidth: width);
        final height = painter.height;
        painter.dispose();
        return height;
      }

      // A single long word must not break mid-word at large text sizes.
      final headingText = widget.heading ?? widget.title;
      final headingScaler = academyFitTextScaler(
        context,
        headingText,
        style,
        width.toDouble(),
      );
      final headingHeight = textHeight(headingText, style, headingScaler);
      final eyebrowStyle = theme.textTheme.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: .6,
        color: theme.colorScheme.onSurfaceVariant,
      );
      final eyebrowHeight = widget.eyebrow == null
          ? 0.0
          : textHeight(widget.eyebrow!, eyebrowStyle) + 8;
      final threshold = eyebrowHeight + headingHeight + academyChromeContentGap;
      bool compact() => _scroll.hasClients && _scroll.offset >= threshold;

      return PrimaryScrollController(
        controller: _scroll,
        child: AcademyPage(
          title: widget.title,
          showBackButton: !widget.tab,
          headerBackgroundBuilder: (context, _) => AnimatedBuilder(
            key: const ValueKey('large-title-header-background'),
            animation: _scroll,
            builder: (context, _) =>
                compact() ? const _HeaderFade() : const SizedBox.shrink(),
          ),
          titleWidget: AnimatedBuilder(
            animation: _scroll,
            builder: (context, _) => compact()
                ? Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  )
                : const SizedBox.shrink(),
          ),
          child: Builder(
            builder: (context) => ListView(
              key: widget.scrollKey,
              primary: true,
              padding: EdgeInsets.fromLTRB(
                widget.horizontalPadding,
                AcademyPageInsets.topOf(context),
                widget.horizontalPadding,
                widget.tab
                    ? AcademyFloatingTabBar.bottomObstructionOf(context) + 24
                    : MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                if (widget.eyebrow != null) ...[
                  Text(widget.eyebrow!, style: eyebrowStyle),
                  const SizedBox(height: 8),
                ],
                AnimatedBuilder(
                  animation: _scroll,
                  child: Semantics(
                    header: true,
                    child: Text(
                      headingText,
                      style: style,
                      textScaler: headingScaler,
                    ),
                  ),
                  builder: (context, child) =>
                      compact() ? SizedBox(height: headingHeight) : child!,
                ),
                SizedBox(height: widget.titleGap),
                ...widget.children,
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Protects the compact title while fading softly into the scrolling content.
class _HeaderFade extends StatelessWidget {
  const _HeaderFade();

  @override
  Widget build(BuildContext context) {
    final canvas = AcademyTheme.of(context).scaffoldBackgroundColor;
    final top = academyChromeTopOf(context);
    final bar = academyChromeHeightOf(context);
    final height = top + bar + 20;
    // Keep underlying text faint through the title, then reveal it at the edge.
    final protectedFraction = (top + bar * .65) / height;
    const alpha = .94;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, protectedFraction, 1],
          colors: [
            canvas.withValues(alpha: alpha),
            canvas.withValues(alpha: alpha),
            canvas.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
