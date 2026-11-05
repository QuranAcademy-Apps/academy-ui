import 'package:flutter/cupertino.dart';

import '../../foundation/localizations/academy_localizations.dart';
import '../../foundation/loading/academy_skeleton.dart';
import '../../foundation/motion/soft_fade_in.dart';
import '../../foundation/motion/soft_fade_switcher.dart';

/// Builds the provider for an accepted HTTPS [url]. Apps pass a disk-cached
/// provider here (for example `CachedNetworkImageProvider`); the default is
/// the in-memory [NetworkImage].
typedef AcademyImageProviderBuilder = ImageProvider Function(String url);

/// Public HTTPS media with a skeleton while loading, a soft fade-in and the
/// caller's [fallback] for invalid URLs and errors. Ported from Yalla.
class AcademyNetworkImage extends StatelessWidget {
  const AcademyNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.semanticLabel,
    this.width,
    this.height,
    this.cacheWidth,
    this.autoCacheWidth = false,
    this.gaplessPlayback = false,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.provider,
  });

  final String url;
  final Widget fallback;
  final String? semanticLabel;
  final double? width, height;
  final int? cacheWidth;

  /// Decodes at [width] times the device pixel ratio, unless [cacheWidth] is
  /// set: a full-size photo otherwise fills the image cache.
  final bool autoCacheWidth;
  final bool gaplessPlayback;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;
  final AcademyImageProviderBuilder? provider;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return fallback;
    }
    final loadingLabel = AcademyLocalizations.of(context).imageLoading;
    final logicalWidth = width;
    final decodeWidth =
        cacheWidth ??
        (autoCacheWidth && logicalWidth != null && logicalWidth.isFinite
            ? (logicalWidth * MediaQuery.devicePixelRatioOf(context)).round()
            : null);
    return Image(
      // Keep a lower tier only for the same source; a new URL resets pixels.
      key: gaplessPlayback ? ValueKey(url) : null,
      gaplessPlayback: gaplessPlayback,
      image: ResizeImage.resizeIfNeeded(
        decodeWidth,
        null,
        provider?.call(url) ?? NetworkImage(url),
      ),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      semanticLabel: semanticLabel,
      frameBuilder: (context, child, frame, synchronous) {
        if (synchronous && !gaplessPlayback) return child;
        Widget presentation(bool ready) => synchronous
            ? child
            : SoftFadeSwitcher(
                duration: AcademyContentMotion.duration,
                switchInCurve: AcademyContentMotion.curve,
                switchOutCurve: AcademyContentMotion.curve,
                initialOffset: Offset.zero,
                initialScale: 1,
                // Keep the same image bounds for asynchronous and cached frames.
                // AnimatedSwitcher's default Stack loosens the parent constraints.
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [...previous, ?current],
                ),
                child: ready
                    ? KeyedSubtree(key: const ValueKey('image'), child: child)
                    : Semantics(
                        key: const ValueKey('loading'),
                        label: loadingLabel,
                        child: ExcludeSemantics(
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: const AcademySkeletonBlock(
                              height: double.infinity,
                              radius: 0,
                            ),
                          ),
                        ),
                      ),
              );
        return gaplessPlayback
            ? _GaplessImageFrame(
                key: ValueKey(url),
                ready: frame != null,
                builder: presentation,
              )
            : presentation(frame != null);
      },
      errorBuilder: (context, error, stackTrace) =>
          SoftFadeIn(key: ValueKey((url, 'error')), child: fallback),
    );
  }
}

/// Image.gaplessPlayback retains pixels between resize providers. Keep the
/// loading presentation from covering those pixels while a larger tier decodes.
/// URL identity resets this state, so another photo never inherits old content.
class _GaplessImageFrame extends StatefulWidget {
  const _GaplessImageFrame({
    super.key,
    required this.ready,
    required this.builder,
  });
  final bool ready;
  final Widget Function(bool ready) builder;

  @override
  State<_GaplessImageFrame> createState() => _GaplessImageFrameState();
}

class _GaplessImageFrameState extends State<_GaplessImageFrame> {
  late bool _seenFrame = widget.ready;

  @override
  void didUpdateWidget(_GaplessImageFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seenFrame = _seenFrame || widget.ready;
  }

  @override
  Widget build(BuildContext context) => widget.builder(_seenFrame);
}
