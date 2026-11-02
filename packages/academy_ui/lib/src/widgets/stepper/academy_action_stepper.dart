// Ported from quran_flutter AppStepper.
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../icon/academy_sf_image.dart';

/// 94 x 32 minus/plus pill. A null callback dims its half; [color] tints the
/// track, divider and symbols.
class AcademyActionStepper extends StatelessWidget {
  const AcademyActionStepper({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    required this.color,
    this.centered = false,
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

  @override
  Widget build(BuildContext context) {
    final frameLeft = (_hitWidth - _frameWidth) / (centered ? 2 : 1);
    final minusIconLeft = frameLeft + ((_frameWidth / 2) - _iconSize) / 2;
    final plusIconLeft = minusIconLeft + _frameWidth / 2;

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
                borderRadius: BorderRadius.circular(8),
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
              // directions, so the hit areas must not mirror under RTL.
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: _AcademyActionStepperHit(onPressed: onDecrease),
                ),
                Expanded(
                  child: _AcademyActionStepperHit(onPressed: onIncrease),
                ),
              ],
            ),
          ),
          Positioned(
            left: minusIconLeft,
            top: _iconTop,
            child: _AcademyActionStepperIcon(
              icon: AcademySymbols.minus,
              isEnabled: onDecrease != null,
              color: color,
            ),
          ),
          Positioned(
            left: plusIconLeft,
            top: _iconTop,
            child: _AcademyActionStepperIcon(
              icon: AcademySymbols.plus,
              isEnabled: onIncrease != null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademyActionStepperHit extends StatelessWidget {
  const _AcademyActionStepperHit({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: isEnabled
          ? () {
              HapticFeedback.selectionClick();
              onPressed?.call();
            }
          : null,
      child: const SizedBox.expand(),
    );
  }
}

class _AcademyActionStepperIcon extends StatelessWidget {
  const _AcademyActionStepperIcon({
    required this.icon,
    required this.isEnabled,
    required this.color,
  });

  final Color color;
  final IconData icon;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Icon(
        icon,
        size: AcademyActionStepper._iconSize,
        color: isEnabled ? color : color.withValues(alpha: 0.35),
      ),
    );
  }
}
