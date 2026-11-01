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
  static const textAlignRight = sf.SFIcons.sf_text_alignright;
  static const textAlignLeft = sf.SFIcons.sf_text_alignleft;
  static const lineBreaks = sf.SFIcons.sf_return;
  static const textJustify = sf.SFIcons.sf_text_justify;
  static const textFormat = sf.SFIcons.sf_textformat;
  static const lightbulb = sf.SFIcons.sf_lightbulb;
  static const forwardEnd = sf.SFIcons.sf_forward_end;
  static const waveform = sf.SFIcons.sf_waveform;

  // Symbols used by the Quran app (migrated from its AppSfIcons catalog).
  static const antennaRadiowavesLeftRight =
      sf.SFIcons.sf_antenna_radiowaves_left_and_right;
  static const archivebox = sf.SFIcons.sf_archivebox;
  static const arrowDown = sf.SFIcons.sf_arrow_down;
  static const arrowDownCircle = sf.SFIcons.sf_arrow_down_circle;
  static const arrowLeftAndRight = sf.SFIcons.sf_arrow_left_and_right;
  static const arrowUpArrowDown = sf.SFIcons.sf_arrow_up_arrow_down;
  static const arrowUpRight = sf.SFIcons.sf_arrow_up_right;
  static const chevronLeft = sf.SFIcons.sf_chevron_left;
  static const backwardEndFill = sf.SFIcons.sf_backward_end_fill;
  static const backwardFill = sf.SFIcons.sf_backward_fill;
  static const bellBadgeFill = sf.SFIcons.sf_bell_badge_fill;
  static const bookClosed = sf.SFIcons.sf_book_closed;
  static const bookPages = sf.SFIcons.sf_book_pages;
  static const bookCircleFill = sf.SFIcons.sf_book_circle_fill;
  static const bookFill = sf.SFIcons.sf_book_fill;
  static const bookmarkCircleFill = sf.SFIcons.sf_bookmark_circle_fill;
  static const calendarBadgeCheckmark = sf.SFIcons.sf_calendar_badge_checkmark;
  static const chartBarAltFill = sf.SFIcons.sf_chart_bar_fill;
  static const chevronDownDouble = sf.SFIcons.sf_chevron_down_2;
  static const characterBubble = sf.SFIcons.sf_character_bubble;
  static const chevronRight = sf.SFIcons.sf_chevron_right;
  static const circleLefthalfFill = sf.SFIcons.sf_circle_lefthalf_filled;
  static const cloudDownload = sf.SFIcons.sf_icloud_and_arrow_down;
  static const cloudDownloadFill = sf.SFIcons.sf_icloud_and_arrow_down_fill;
  static const cylinderFill = sf.SFIcons.sf_cylinder_split_1x2_fill;
  static const devicePhoneLandscape = sf.SFIcons.sf_iphone_landscape;
  static const devicePhonePortrait = sf.SFIcons.sf_iphone;
  static const docOnDoc = sf.SFIcons.sf_document_on_document;
  static const dotRadiowavesLeftRight =
      sf.SFIcons.sf_dot_radiowaves_left_and_right;
  static const ellipsisBubbleFill = sf.SFIcons.sf_ellipsis_bubble_fill;
  static const exclamationmarkCircle = sf.SFIcons.sf_exclamationmark_circle;
  static const exclamationmarkTriangle = sf.SFIcons.sf_exclamationmark_triangle;
  static const exclamationmarkTriangleFill =
      sf.SFIcons.sf_exclamationmark_triangle_fill;
  static const forwardEndFill = sf.SFIcons.sf_forward_end_fill;
  static const forwardFill = sf.SFIcons.sf_forward_fill;
  static const flag = sf.SFIcons.sf_flag;
  static const flameOutline = sf.SFIcons.sf_flame;
  static const folder = sf.SFIcons.sf_folder;
  static const folderCircleFill = sf.SFIcons.sf_folder_circle_fill;
  static const folderFill = sf.SFIcons.sf_folder_fill;
  static const gearSolid = sf.SFIcons.sf_gearshape_fill;
  static const globeFull = sf.SFIcons.sf_globe;
  static const heartFill = sf.SFIcons.sf_heart_fill;
  static const hifispeaker = sf.SFIcons.sf_hifispeaker;
  static const history =
      sf.SFIcons.sf_clock_arrow_trianglehead_counterclockwise_rotate_90;
  static const infinite = sf.SFIcons.sf_infinity;
  static const infoCircleFill = sf.SFIcons.sf_info_circle_fill;
  static const lightbulbFill = sf.SFIcons.sf_lightbulb_fill;
  static const locationArrow = sf.SFIcons.sf_location;
  static const minusCircleFill = sf.SFIcons.sf_minus_circle_fill;
  static const plusCircleFill = sf.SFIcons.sf_plus_circle_fill;
  static const moonFill = sf.SFIcons.sf_moon_fill;
  static const musicNote2 = sf.SFIcons.sf_music_note;
  static const nosign = sf.SFIcons.sf_nosign;
  static const pageHorizontal =
      sf.SFIcons.sf_rectangle_portrait_arrowtriangle_2_outward;
  static const pageVertical = sf.SFIcons.sf_rectangle_arrowtriangle_2_outward;
  static const pencil = sf.SFIcons.sf_pencil;
  static const pencilLine = sf.SFIcons.sf_pencil_line;
  static const personCircle = sf.SFIcons.sf_person_circle;
  static const photoOnRectangle = sf.SFIcons.sf_photo_on_rectangle;
  static const pin = sf.SFIcons.sf_pin;
  static const pinSlash = sf.SFIcons.sf_pin_slash;
  static const playTvFill = sf.SFIcons.sf_play_tv_fill;
  static const magnifyingglassPlus = sf.SFIcons.sf_plus_magnifyingglass;
  static const quoteBubble = sf.SFIcons.sf_bubble_left;
  static const refresh = sf.SFIcons.sf_arrow_clockwise;
  static const repeat = sf.SFIcons.sf_repeat;
  static const repeat1 = sf.SFIcons.sf_repeat_1;
  static const zoom =
      sf.SFIcons.sf_arrow_up_left_and_down_right_magnifyingglass;
  static const squareAndPencil = sf.SFIcons.sf_square_and_pencil;
  static const shuffle = sf.SFIcons.sf_shuffle;
  static const speaker2 = sf.SFIcons.sf_speaker_wave_2;
  static const speaker3Fill = sf.SFIcons.sf_speaker_wave_3_fill;
  static const speakerFill = sf.SFIcons.sf_speaker_fill;
  static const speakerSlashFill = sf.SFIcons.sf_speaker_slash_fill;
  static const speedometer =
      sf.SFIcons.sf_gauge_with_dots_needle_bottom_50percent;
  static const starCircleFill = sf.SFIcons.sf_star_circle_fill;
  static const starFill = sf.SFIcons.sf_star_fill;
  static const stopCircle = sf.SFIcons.sf_stop_circle;
  static const stopFill = sf.SFIcons.sf_stop_fill;
  static const sunMaxFill = sf.SFIcons.sf_sun_max_fill;
  static const textBubble = sf.SFIcons.sf_text_bubble;
  static const textWordSpacing = sf.SFIcons.sf_text_word_spacing;
  static const translate = sf.SFIcons.sf_translate;
  static const trashFill = sf.SFIcons.sf_trash_fill;
  static const trayArrowDown = sf.SFIcons.sf_tray_and_arrow_down;
  static const viewfinder = sf.SFIcons.sf_viewfinder;
  static const wifi = sf.SFIcons.sf_wifi;
  static const wifiSlash = sf.SFIcons.sf_wifi_slash;
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
