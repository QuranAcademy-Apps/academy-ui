import 'package:flutter/widgets.dart';

import '../widgets/icon/academy_sf_image.dart';

/// Glyphs the library draws on its own, such as a row's chevron or a field's
/// clear button. A client replaces any of them through its theme; [IconData]
/// from any font works. Icons a client passes to a widget are unaffected.
@immutable
class AcademyIcons {
  const AcademyIcons({
    this.back = AcademySymbols.back,
    this.calendar = AcademySymbols.calendar,
    this.checkmark = AcademySymbols.checkmark,
    this.clear = AcademySymbols.clear,
    this.clock = AcademySymbols.clock,
    this.close = AcademySymbols.close,
    this.complete = AcademySymbols.completeFill,
    this.down = AcademySymbols.down,
    this.dragHandle = AcademySymbols.dragHandle,
    this.empty = AcademySymbols.search,
    this.error = AcademySymbols.exclamationmarkCircle,
    this.forward = AcademySymbols.forward,
    this.info = AcademySymbols.info,
    this.loadError = AcademySymbols.cloud,
    this.lock = AcademySymbols.lock,
    this.minus = AcademySymbols.minus,
    this.more = AcademySymbols.more,
    this.photo = AcademySymbols.photo,
    this.play = AcademySymbols.playFill,
    this.plus = AcademySymbols.plus,
    this.readOnly = AcademySymbols.lockOutline,
    this.search = AcademySymbols.search,
    this.trash = AcademySymbols.trash,
    this.up = AcademySymbols.up,
    this.upDown = AcademySymbols.upDown,
  });

  final IconData back;
  final IconData calendar;
  final IconData checkmark;
  final IconData clear;
  final IconData clock;
  final IconData close;
  final IconData complete;
  final IconData down;
  final IconData dragHandle;
  final IconData empty;
  final IconData error;
  final IconData forward;
  final IconData info;
  final IconData loadError;
  final IconData lock;
  final IconData minus;
  final IconData more;
  final IconData photo;
  final IconData play;
  final IconData plus;
  final IconData readOnly;
  final IconData search;
  final IconData trash;
  final IconData up;
  final IconData upDown;

  AcademyIcons copyWith({
    IconData? back,
    IconData? calendar,
    IconData? checkmark,
    IconData? clear,
    IconData? clock,
    IconData? close,
    IconData? complete,
    IconData? down,
    IconData? dragHandle,
    IconData? empty,
    IconData? error,
    IconData? forward,
    IconData? info,
    IconData? loadError,
    IconData? lock,
    IconData? minus,
    IconData? more,
    IconData? photo,
    IconData? play,
    IconData? plus,
    IconData? readOnly,
    IconData? search,
    IconData? trash,
    IconData? up,
    IconData? upDown,
  }) => AcademyIcons(
    back: back ?? this.back,
    calendar: calendar ?? this.calendar,
    checkmark: checkmark ?? this.checkmark,
    clear: clear ?? this.clear,
    clock: clock ?? this.clock,
    close: close ?? this.close,
    complete: complete ?? this.complete,
    down: down ?? this.down,
    dragHandle: dragHandle ?? this.dragHandle,
    empty: empty ?? this.empty,
    error: error ?? this.error,
    forward: forward ?? this.forward,
    info: info ?? this.info,
    loadError: loadError ?? this.loadError,
    lock: lock ?? this.lock,
    minus: minus ?? this.minus,
    more: more ?? this.more,
    photo: photo ?? this.photo,
    play: play ?? this.play,
    plus: plus ?? this.plus,
    readOnly: readOnly ?? this.readOnly,
    search: search ?? this.search,
    trash: trash ?? this.trash,
    up: up ?? this.up,
    upDown: upDown ?? this.upDown,
  );
}
