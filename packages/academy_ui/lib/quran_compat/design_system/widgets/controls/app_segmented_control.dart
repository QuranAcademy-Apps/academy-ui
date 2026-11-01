import 'package:academy_ui/academy_ui.dart'
    show
        AcademySlidingSegments,
        academySlidingSegmentsCurve,
        academySlidingSegmentsDuration;

/// Quran name for academy_ui's sliding segmented selector.
typedef AppSegmentedControl<T extends Object> = AcademySlidingSegments<T>;

const appSegmentedControlAnimationDuration = academySlidingSegmentsDuration;
const appSegmentedControlAnimationCurve = academySlidingSegmentsCurve;
