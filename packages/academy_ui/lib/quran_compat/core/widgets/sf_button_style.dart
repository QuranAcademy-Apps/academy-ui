import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_sficon/flutter_sficon.dart' as sf;

import '../../theme/app_colors.dart';

// Shared SF button/image styling types, used by `SFButton` and `SFImageView`.

enum SFButtonType { image, withBackground }

/// iOS SFImageView.Size equivalent.
class SFButtonSize {
  final Size frameSize;
  final double symbolSize;

  const SFButtonSize._(this.frameSize, this.symbolSize);

  const SFButtonSize.custom({
    required this.frameSize,
    required this.symbolSize,
  });

  static const standard = SFButtonSize._(Size(30, 30), 15);
  static const medium = SFButtonSize._(Size(40, 40), 15);
  static const large = SFButtonSize._(Size(44, 44), 16);
}

/// Background presets matching the iOS SFIconButtonBackground.
enum SFIconButtonBackground { content, bar }

extension SFIconButtonBackgroundColors on SFIconButtonBackground {
  Color resolve(AppColors? colors) {
    switch (this) {
      case .content:
        return colors?.backgroundPrimary ?? CupertinoColors.white;
      case .bar:
        return colors?.backgroundControl ?? CupertinoColors.systemGrey6;
    }
  }
}

IconData sfIconDataForSystemName(String systemName) {
  switch (systemName.trim()) {
    case 'chevron.left':
      return sf.SFIcons.sf_chevron_left;
    case 'chevron.right':
      return sf.SFIcons.sf_chevron_right;
    case 'chevron.up':
      return sf.SFIcons.sf_chevron_up;
    case 'chevron.down':
      return sf.SFIcons.sf_chevron_down;
    case 'chevron.up.chevron.down':
      return sf.SFIcons.sf_chevron_up_chevron_down;
    case 'chevron.back':
      return sf.SFIcons.sf_chevron_backward;
    case 'chevron.forward':
      return sf.SFIcons.sf_chevron_forward;
    case 'play':
      return sf.SFIcons.sf_play;
    case 'play.fill':
      return sf.SFIcons.sf_play_fill;
    case 'pause':
      return sf.SFIcons.sf_pause;
    case 'pause.fill':
      return sf.SFIcons.sf_pause_fill;
    case 'stop':
      return sf.SFIcons.sf_stop;
    case 'stop.fill':
      return sf.SFIcons.sf_stop_fill;
    case 'forward':
      return sf.SFIcons.sf_forward;
    case 'backward':
      return sf.SFIcons.sf_backward;
    case 'forward.fill':
      return sf.SFIcons.sf_forward_fill;
    case 'backward.fill':
      return sf.SFIcons.sf_backward_fill;
    case 'goforward':
      return sf.SFIcons.sf_arrow_clockwise;
    case 'repeat':
      return sf.SFIcons.sf_repeat;
    case 'bookmark':
      return sf.SFIcons.sf_bookmark;
    case 'bookmark.fill':
      return sf.SFIcons.sf_bookmark_fill;
    case 'heart':
      return sf.SFIcons.sf_heart;
    case 'heart.fill':
      return sf.SFIcons.sf_heart_fill;
    case 'star':
      return sf.SFIcons.sf_star;
    case 'star.fill':
      return sf.SFIcons.sf_star_fill;
    case 'star.lefthalf.fill':
      return sf.SFIcons.sf_star_leadinghalf_filled;
    case 'magnifyingglass':
      return sf.SFIcons.sf_magnifyingglass;
    case 'magnifyingglass.circle':
      return sf.SFIcons.sf_magnifyingglass_circle;
    case 'magnifyingglass.circle.fill':
      return sf.SFIcons.sf_magnifyingglass_circle_fill;
    case 'radio':
      return sf.SFIcons.sf_radio;
    case 'radio.fill':
      return sf.SFIcons.sf_radio_fill;
    case 'dot.radiowaves.left.and.right':
      return sf.SFIcons.sf_dot_radiowaves_left_and_right;
    case 'dot.radiowaves.right':
      return sf.SFIcons.sf_dot_radiowaves_right;
    case 'gear':
      return sf.SFIcons.sf_gear;
    case 'gearshape':
      return sf.SFIcons.sf_gearshape;
    case 'gearshape.fill':
      return sf.SFIcons.sf_gearshape_fill;
    case 'gear.alt':
      return sf.SFIcons.sf_gearshape;
    case 'gear.alt.fill':
      return sf.SFIcons.sf_gearshape_fill;
    case 'slider.horizontal.3':
      return sf.SFIcons.sf_slider_horizontal_3;
    case 'ellipsis':
      return sf.SFIcons.sf_ellipsis;
    case 'ellipsis.circle':
      return sf.SFIcons.sf_ellipsis_circle;
    case 'ellipsis.circle.fill':
      return sf.SFIcons.sf_ellipsis_circle_fill;
    case 'list.bullet':
      return sf.SFIcons.sf_list_bullet;
    case 'list.bullet.indent':
      return sf.SFIcons.sf_list_bullet_indent;
    case 'list.bullet.rectangle.portrait':
      return sf.SFIcons.sf_list_bullet_rectangle_portrait;
    case 'list.number':
      return sf.SFIcons.sf_list_number;
    case 'list.dash':
      return sf.SFIcons.sf_list_dash;
    case 'square.and.arrow.up':
      return sf.SFIcons.sf_square_and_arrow_up;
    case 'square.and.arrow.down':
      return sf.SFIcons.sf_square_and_arrow_down;
    case 'square.and.arrow.up.on.square':
      return sf.SFIcons.sf_square_and_arrow_up_on_square;
    case 'square.and.arrow.down.on.square':
      return sf.SFIcons.sf_square_and_arrow_down_on_square;
    case 'trash':
      return sf.SFIcons.sf_trash;
    case 'trash.fill':
      return sf.SFIcons.sf_trash_fill;
    case 'pencil':
      return sf.SFIcons.sf_pencil;
    case 'pencil.circle':
      return sf.SFIcons.sf_pencil_circle;
    case 'pencil.circle.fill':
      return sf.SFIcons.sf_pencil_circle_fill;
    case 'pencil.and.outline':
      return sf.SFIcons.sf_pencil_and_outline;
    case 'plus':
      return sf.SFIcons.sf_plus;
    case 'plus.circle':
      return sf.SFIcons.sf_plus_circle;
    case 'plus.circle.fill':
      return sf.SFIcons.sf_plus_circle_fill;
    case 'minus':
      return sf.SFIcons.sf_minus;
    case 'minus.circle':
      return sf.SFIcons.sf_minus_circle;
    case 'minus.circle.fill':
      return sf.SFIcons.sf_minus_circle_fill;
    case 'xmark':
      return sf.SFIcons.sf_xmark;
    case 'xmark.circle':
      return sf.SFIcons.sf_xmark_circle;
    case 'xmark.circle.fill':
      return sf.SFIcons.sf_xmark_circle_fill;
    case 'checkmark':
      return sf.SFIcons.sf_checkmark;
    case 'checkmark.circle':
      return sf.SFIcons.sf_checkmark_circle;
    case 'checkmark.circle.fill':
      return sf.SFIcons.sf_checkmark_circle_fill;
    case 'message':
      return sf.SFIcons.sf_message;
    case 'message.fill':
      return sf.SFIcons.sf_message_fill;
    case 'bubble.left':
      return sf.SFIcons.sf_bubble_left;
    case 'bubble.left.fill':
      return sf.SFIcons.sf_bubble_left_fill;
    case 'bubble.right':
      return sf.SFIcons.sf_bubble_right;
    case 'bubble.right.fill':
      return sf.SFIcons.sf_bubble_right_fill;
    case 'doc':
      return sf.SFIcons.sf_document;
    case 'doc.fill':
      return sf.SFIcons.sf_document_fill;
    case 'doc.on.doc':
      return sf.SFIcons.sf_document_on_document;
    case 'doc.text':
      return sf.SFIcons.sf_text_page;
    case 'text.document':
      return sf.SFIcons.sf_text_document;
    case 'book':
      return sf.SFIcons.sf_book;
    case 'book.fill':
      return sf.SFIcons.sf_book_fill;
    case 'text.book.closed':
      return sf.SFIcons.sf_text_book_closed;
    case 'text.page.slash.fill':
      return sf.SFIcons.sf_text_page_slash_fill;
    case 'folder':
      return sf.SFIcons.sf_folder;
    case 'folder.fill':
      return sf.SFIcons.sf_folder_fill;
    case 'folder.open':
      return sf.SFIcons.sf_folder;
    case 'clock':
      return sf.SFIcons.sf_clock;
    case 'clock.fill':
      return sf.SFIcons.sf_clock_fill;
    case 'calendar':
      return sf.SFIcons.sf_calendar;
    case 'calendar.badge.plus':
      return sf.SFIcons.sf_calendar_badge_plus;
    case 'calendar.badge.minus':
      return sf.SFIcons.sf_calendar_badge_minus;
    case 'person':
      return sf.SFIcons.sf_person;
    case 'person.fill':
      return sf.SFIcons.sf_person_fill;
    case 'person.circle':
      return sf.SFIcons.sf_person_circle;
    case 'person.circle.fill':
      return sf.SFIcons.sf_person_circle_fill;
    case 'person.2':
      return sf.SFIcons.sf_person_2;
    case 'person.2.fill':
      return sf.SFIcons.sf_person_2_fill;
    case 'location':
      return sf.SFIcons.sf_location;
    case 'location.fill':
      return sf.SFIcons.sf_location_fill;
    case 'map':
      return sf.SFIcons.sf_map;
    case 'map.fill':
      return sf.SFIcons.sf_map_fill;
    case 'sun.max':
      return sf.SFIcons.sf_sun_max;
    case 'sun.max.fill':
      return sf.SFIcons.sf_sun_max_fill;
    case 'moon':
      return sf.SFIcons.sf_moon;
    case 'moon.fill':
      return sf.SFIcons.sf_moon_fill;
    case 'cloud':
      return sf.SFIcons.sf_cloud;
    case 'cloud.fill':
      return sf.SFIcons.sf_cloud_fill;
    case 'info.circle':
      return sf.SFIcons.sf_info_circle;
    case 'arrow.uturn.backward':
      return sf.SFIcons.sf_arrow_uturn_backward;
    case 'arrow.clockwise':
      return sf.SFIcons.sf_arrow_clockwise;
    case 'arrow.down.circle':
      return sf.SFIcons.sf_arrow_down_circle;
    default:
      return sf.SFIcons.sf_questionmark_circle;
  }
}
