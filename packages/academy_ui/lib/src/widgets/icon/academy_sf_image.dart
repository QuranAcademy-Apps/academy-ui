// Adapted from quran_flutter/lib/core/widgets/app_sf_icon.dart.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_sficon/flutter_sficon.dart' as sf;

class AcademySfIcon extends StatelessWidget {
  const AcademySfIcon(
    this.icon, {
    super.key,
    this.fontSize,
    this.size,
    this.boxSize,
    this.paintExtent,
    this.fontWeight,
    this.color,
    this.shadows,
    this.textDirection,
    this.semanticsLabel,
    this.scaleWithText = false,
    this.mirrorInRtl = true,
  });

  final IconData icon;
  final double? fontSize;
  final double? size;
  final double? boxSize;
  final double? paintExtent;
  final FontWeight? fontWeight;
  final Color? color;
  final List<Shadow>? shadows;
  final TextDirection? textDirection;
  final String? semanticsLabel;

  /// Follow the ambient text scale. Off by default: symbols keep a fixed size.
  final bool scaleWithText;

  /// Swap [AcademySymbols.back] and [AcademySymbols.forward] in RTL. Turn off
  /// when the host relies on the glyph's own right-to-left variant.
  final bool mirrorInRtl;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = fontSize ?? size ?? 24;
    final direction = textDirection ?? Directionality.of(context);
    final resolvedIcon = mirrorInRtl && direction == TextDirection.rtl
        ? icon == AcademySymbols.back
              ? AcademySymbols.forward
              : icon == AcademySymbols.forward
              ? AcademySymbols.back
              : icon
        : icon;
    final symbol = ExcludeSemantics(
      excluding: semanticsLabel == null,
      child: sf.SFIcon(
        resolvedIcon,
        fontSize: resolvedSize,
        fontWeight: fontWeight,
        color: color,
        shadows: shadows,
        textDirection: direction,
        semanticsLabel: semanticsLabel,
      ),
    );
    final glyph = scaleWithText
        ? symbol
        : MediaQuery.withNoTextScaling(child: symbol);

    final resolvedBoxSize = boxSize;
    if (resolvedBoxSize == null) return glyph;

    final resolvedPaintExtent =
        paintExtent ?? math.max(resolvedBoxSize, resolvedSize + 8);

    return SizedBox.square(
      dimension: resolvedBoxSize,
      child: Center(
        child: OverflowBox(
          minWidth: resolvedPaintExtent,
          maxWidth: resolvedPaintExtent,
          minHeight: resolvedPaintExtent,
          maxHeight: resolvedPaintExtent,
          child: Center(child: glyph),
        ),
      ),
    );
  }
}

abstract final class AcademySymbols {
  static const dragHandle = sf.SFIcons.sf_line_3_horizontal;
  static const heart = sf.SFIcons.sf_heart;
  static const phone = sf.SFIcons.sf_phone;
  static const lock = sf.SFIcons.sf_lock_fill;
  static const person = sf.SFIcons.sf_person;
  static const circuit = sf.SFIcons.sf_arrow_counterclockwise;
  static const walk = sf.SFIcons.sf_figure_walk;
  static const complete = sf.SFIcons.sf_checkmark_circle;
  static const plus = sf.SFIcons.sf_plus;
  static const minus = sf.SFIcons.sf_minus;
  static const info = sf.SFIcons.sf_info_circle;
  static const gear = sf.SFIcons.sf_gearshape;
  static const sun = sf.SFIcons.sf_sun_max;
  static const moon = sf.SFIcons.sf_moon;
  static const airplane = sf.SFIcons.sf_airplane;
  static const bus = sf.SFIcons.sf_bus;
  static const train = sf.SFIcons.sf_tram;
  static const car = sf.SFIcons.sf_car;
  static const calendar = sf.SFIcons.sf_calendar;
  static const checklist = sf.SFIcons.sf_checklist;
  static const book = sf.SFIcons.sf_book;
  static const bell = sf.SFIcons.sf_bell;
  static const checkmark = sf.SFIcons.sf_checkmark;
  static const down = sf.SFIcons.sf_chevron_down;
  static const up = sf.SFIcons.sf_chevron_up;
  static const upDown = sf.SFIcons.sf_chevron_up_chevron_down;
  static const play = sf.SFIcons.sf_play;
  static const rotate = sf.SFIcons.sf_rectangle_portrait_rotate;
  static const forward = sf.SFIcons.sf_chevron_forward;
  static const back = sf.SFIcons.sf_chevron_backward;
  static const cloud = sf.SFIcons.sf_cloud;
  static const search = sf.SFIcons.sf_magnifyingglass;
  static const photo = sf.SFIcons.sf_photo;
  static const close = sf.SFIcons.sf_xmark;
  static const clear = sf.SFIcons.sf_xmark_circle_fill;
  static const flame = sf.SFIcons.sf_flame_fill;
  static const filters = sf.SFIcons.sf_slider_horizontal_3;
  static const location = sf.SFIcons.sf_mappin;
  static const tag = sf.SFIcons.sf_tag;
  static const clock = sf.SFIcons.sf_clock;
  static const bed = sf.SFIcons.sf_bed_double;
  static const group = sf.SFIcons.sf_person_2;
  static const creditcard = sf.SFIcons.sf_creditcard;
  static const meal = sf.SFIcons.sf_fork_knife;
  static const document = sf.SFIcons.sf_document;
  static const shield = sf.SFIcons.sf_shield;
  static const envelope = sf.SFIcons.sf_envelope;
  static const trash = sf.SFIcons.sf_trash;
  static const logout = sf.SFIcons.sf_rectangle_portrait_and_arrow_right;
  static const expand = sf.SFIcons.sf_arrow_up_left_and_arrow_down_right;
  static const bookmark = sf.SFIcons.sf_bookmark;
  static const bookmarkFill = sf.SFIcons.sf_bookmark_fill;
  static const share = sf.SFIcons.sf_square_and_arrow_up;
  static const more = sf.SFIcons.sf_ellipsis;
  static const textSize = sf.SFIcons.sf_textformat_size;
  static const sunrise = sf.SFIcons.sf_sunrise;
  static const sunset = sf.SFIcons.sf_sunset;
  static const moonStars = sf.SFIcons.sf_moon_stars;
  static const sparkles = sf.SFIcons.sf_sparkles;
  static const list = sf.SFIcons.sf_list_bullet;
  static const quote = sf.SFIcons.sf_quote_opening;
  static const reset = sf.SFIcons.sf_arrow_uturn_backward;
  static const handTap = sf.SFIcons.sf_hand_tap;
  static const completeFill = sf.SFIcons.sf_checkmark_circle_fill;
  static const plusCircle = sf.SFIcons.sf_plus_circle;
  static const circle = sf.SFIcons.sf_circle;
  static const restart = sf.SFIcons.sf_arrow_counterclockwise;
  static const pause = sf.SFIcons.sf_pause;
  static const playFill = sf.SFIcons.sf_play_fill;
  static const pauseFill = sf.SFIcons.sf_pause_fill;
  static const house = sf.SFIcons.sf_house;
  static const columns = sf.SFIcons.sf_building_columns;
  static const sunHorizon = sf.SFIcons.sf_sun_horizon;
  static const weather = sf.SFIcons.sf_cloud_sun_rain;
  static const conversation = sf.SFIcons.sf_bubble_left_and_bubble_right;
  static const family = sf.SFIcons.sf_figure_2_and_child_holdinghands;
  static const moreCircle = sf.SFIcons.sf_ellipsis_circle;
  static const sleep = sf.SFIcons.sf_moon_zzz;
  static const handRaised = sf.SFIcons.sf_hand_raised;
  static const shieldHalf = sf.SFIcons.sf_shield_lefthalf_filled;
  static const suitcase = sf.SFIcons.sf_suitcase;
  static const globe = sf.SFIcons.sf_globe_asia_australia;
  static const playCircle = sf.SFIcons.sf_play_circle;
  static const textAlignCenter = sf.SFIcons.sf_text_aligncenter;
  static const textFormat = sf.SFIcons.sf_textformat;
  static const lightbulb = sf.SFIcons.sf_lightbulb;
  static const forwardEnd = sf.SFIcons.sf_forward_end;
  static const waveform = sf.SFIcons.sf_waveform;
}

/// Quran SFImageView / SFButtonSize composition, without reader dependencies.
class AcademySfImage extends StatelessWidget {
  const AcademySfImage(
    this.icon, {
    super.key,
    this.frameSize = 36,
    this.symbolSize = 18,
    this.weight = FontWeight.w600,
    this.foreground,
    this.background,
  });
  final IconData icon;
  final double frameSize;
  final double symbolSize;
  final FontWeight weight;
  final Color? foreground;
  final Color? background;
  @override
  Widget build(BuildContext context) => Container(
    width: frameSize,
    height: frameSize,
    decoration: background == null
        ? null
        : BoxDecoration(color: background, shape: BoxShape.circle),
    child: Center(
      child: AcademySfIcon(
        icon,
        fontSize: symbolSize,
        fontWeight: weight,
        color: foreground,
        boxSize: symbolSize,
      ),
    ),
  );
}
