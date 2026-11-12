import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';
import '../form/academy_field_decoration.dart';

/// Controlled native Cupertino slider with optional discrete steps.
class AcademySlider extends StatelessWidget {
  const AcademySlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.formatValue,
    this.onChangeStart,
    this.onChangeEnd,
  }) : assert(max > min),
       assert(value >= min && value <= max),
       assert(divisions == null || divisions > 0);
  final double value, min, max;
  final int? divisions;
  final String label;
  final String Function(double)? formatValue;
  final ValueChanged<double>? onChanged, onChangeStart, onChangeEnd;
  @override
  Widget build(BuildContext context) => AcademyFieldDecoration(
    label: label,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: label,
          child: CupertinoSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AcademyTheme.of(context).colorScheme.primary,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
          ),
        ),
        Text(
          formatValue?.call(value) ?? value.toStringAsFixed(1),
          style: AcademyTheme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
