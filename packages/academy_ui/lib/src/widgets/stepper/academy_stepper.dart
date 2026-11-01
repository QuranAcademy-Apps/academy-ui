import '../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import 'academy_action_stepper.dart';

class AcademyStepper extends StatelessWidget {
  const AcademyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
  }) : onDecrease = null,
       onIncrease = null,
       centered = false,
       color = null,
       _actions = false;

  /// Callback-driven variant without a value: each half is enabled when its
  /// callback is non-null. 94 x 32 pill inside a 112 x 44 hit area.
  const AcademyStepper.actions({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    this.centered = false,
    this.color,
  }) : value = 0,
       min = 0,
       max = 0,
       onChanged = _ignoreChange,
       _actions = true;

  final int value, min, max;
  final ValueChanged<int> onChanged;
  final VoidCallback? onDecrease, onIncrease;
  final bool centered;

  /// Tint of the actions variant; defaults to the theme's text color.
  final Color? color;
  final bool _actions;

  static void _ignoreChange(int _) {}

  @override
  Widget build(BuildContext context) {
    if (_actions) {
      return AcademyActionStepper(
        onDecrease: onDecrease,
        onIncrease: onIncrease,
        centered: centered,
        color: color ?? AcademyTheme.of(context).colorScheme.onSurface,
      );
    }
    final color = AcademyTheme.of(context).colorScheme.onSurface;
    Widget hit(bool increase) {
      final enabled = increase ? value < max : value > min;
      return SizedBox(
        width: 48,
        child: Semantics(
          label: increase
              ? AcademyLocalizations.of(context).increase
              : AcademyLocalizations.of(context).decrease,
          value: '$value',
          excludeSemantics: true,
          onTap: enabled
              ? () {
                  AcademyTheme.of(context).interaction.selectionClick();
                  onChanged(value + (increase ? 1 : -1));
                }
              : null,
          button: true,
          enabled: enabled,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: enabled
                ? () {
                    AcademyTheme.of(context).interaction.selectionClick();
                    onChanged(value + (increase ? 1 : -1));
                  }
                : null,
            child: const SizedBox.expand(),
          ),
        ),
      );
    }

    Widget glyph(IconData icon, bool enabled) => IgnorePointer(
      child: MediaQuery.withNoTextScaling(
        child: AcademySfIcon(
          icon,
          size: 17,
          boxSize: 17,
          color: color.withValues(alpha: enabled ? 1 : .35),
        ),
      ),
    );
    return SizedBox(
      width: 96,
      height: 44,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          PositionedDirectional(
            start: 0,
            child: Container(
              width: 96,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(
                  AcademyTheme.of(context).radii.stepper,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 47.5,
            child: Container(
              width: 1,
              height: 18,
              color: color.withValues(alpha: .3),
            ),
          ),
          Positioned.fill(child: Row(children: [hit(false), hit(true)])),
          PositionedDirectional(
            start: 15.5,
            top: 13.5,
            child: glyph(AcademySymbols.minus, value > min),
          ),
          PositionedDirectional(
            start: 63.5,
            top: 13.5,
            child: glyph(AcademySymbols.plus, value < max),
          ),
        ],
      ),
    );
  }
}
