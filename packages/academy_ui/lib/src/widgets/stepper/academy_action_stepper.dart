// Ported from quran_flutter AppStepper.
import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

/// 94 x 32 minus/plus pill in a 112 x 44 hit area. A null callback dims its
/// half; [color] tints the track, divider and symbols.
///
/// The pill sits at the end of its box unless [centered], and the larger minus
/// or plus target reaches toward the row's text. Inside the pill the symbols
/// read minus-left / plus-right in both directions.
class AcademyActionStepper extends StatelessWidget {
  const AcademyActionStepper({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    required this.color,
    this.centered = false,
    this.semanticValue,
  });

  final Color color;

  static const _frameWidth = 94.0;
  static const _frameHeight = 32.0;
  static const _hitWidth = 112.0;
  static const _hitHeight = 44.0;
  static const _iconSize = 17.0;
  static const _iconTop = (_hitHeight - _iconSize) / 2;

  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool centered;

  /// Read by accessibility on both halves, for example the current value.
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final strings = AcademyLocalizations.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final slack = _hitWidth - _frameWidth;
    final frameLeft = centered
        ? slack / 2
        : rtl
        ? 0.0
        : slack;
    final minusIconLeft = frameLeft + ((_frameWidth / 2) - _iconSize) / 2;
    final plusIconLeft = minusIconLeft + _frameWidth / 2;

    Widget icon(IconData symbol, bool enabled, double left) => Positioned(
      left: left,
      top: _iconTop,
      child: IgnorePointer(
        child: MediaQuery.withNoTextScaling(
          child: AcademySfIcon(
            symbol,
            size: theme.sizes.stepperIcon,
            boxSize: _iconSize,
            color: enabled ? color : color.withValues(alpha: 0.35),
          ),
        ),
      ),
    );

    return SizedBox(
      width: _hitWidth,
      height: _hitHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: frameLeft,
            child: Container(
              key: const ValueKey('academy-action-stepper-track'),
              width: _frameWidth,
              height: _frameHeight,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(theme.radii.stepper),
              ),
            ),
          ),
          Positioned(
            left: frameLeft + (_frameWidth / 2) - 0.5,
            child: Container(
              width: 1,
              height: 18,
              color: color.withValues(alpha: 0.3),
            ),
          ),
          Positioned.fill(
            child: Row(
              // The symbols are positioned minus-left / plus-right in both
              // directions, so the hit areas must not mirror under RTL. The
              // split follows the divider, not the middle of the box.
              textDirection: TextDirection.ltr,
              children: [
                SizedBox(
                  width: frameLeft + _frameWidth / 2,
                  child: _AcademyActionStepperHit(
                    label: strings.decrease,
                    value: semanticValue,
                    onPressed: onDecrease,
                  ),
                ),
                Expanded(
                  child: _AcademyActionStepperHit(
                    label: strings.increase,
                    value: semanticValue,
                    onPressed: onIncrease,
                  ),
                ),
              ],
            ),
          ),
          icon(theme.icons.minus, onDecrease != null, minusIconLeft),
          icon(theme.icons.plus, onIncrease != null, plusIconLeft),
        ],
      ),
    );
  }
}

class _AcademyActionStepperHit extends StatelessWidget {
  const _AcademyActionStepperHit({
    required this.label,
    required this.onPressed,
    this.value,
  });

  final String label;
  final String? value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    return AcademyActionSemantics(
      label: label,
      value: value,
      enabled: onPressed != null,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onPressed == null
            ? null
            : () {
                AcademyTheme.of(context).interaction.selectionClick();
                onPressed();
              },
        child: const SizedBox.expand(),
      ),
    );
  }
}
