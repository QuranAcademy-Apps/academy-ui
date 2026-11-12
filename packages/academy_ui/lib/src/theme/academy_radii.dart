import 'package:cupertino_ui/cupertino_ui.dart';

enum AcademyRadiusRole {
  button,
  pillButton,
  field,
  search,
  surface,
  table,
  tableBadge,
  rowIcon,
  status,
  image,
  disclosure,
  stepper,
  menuButton,
  settingsButton,
  segment,
  compactSegment,
  segmentSelection,
  compactSegmentSelection,
  chrome,
  chromeButton,
  expandingSearch,
  tabBar,
  tabSelection,
  toast,
  progress,
  textBlock,
  skeleton,
  modal,
}

/// Immutable component defaults. Explicit widget overrides take precedence.
@immutable
class AcademyRadii {
  static const defaultButton = 14.0;
  static const defaultPillButton = 30.0;
  static const defaultField = 12.0;
  static const defaultSearch = defaultField;
  static const defaultSurface = 14.0;
  static const defaultTable = 24.0;
  static const defaultTableBadge = 8.0;
  static const defaultRowIcon = 7.0;
  static const defaultStatus = 6.0;
  static const defaultImage = 20.0;
  static const defaultDisclosure = defaultSurface;
  static const defaultStepper = 8.0;
  static const defaultMenuButton = 30.0;
  static const defaultSettingsButton = 34.0;
  static const defaultSegment = 16.0;
  static const defaultCompactSegment = 8.0;
  static const defaultSegmentSelection = 14.0;
  static const defaultCompactSegmentSelection = 7.0;
  static const defaultChrome = 28.0;
  static const defaultChromeButton = 22.0;
  static const defaultExpandingSearch = 22.0;
  static const defaultTabBar = 999.0;
  static const defaultTabSelection = 999.0;
  static const defaultToast = 28.0;
  static const defaultProgress = 3.0;
  static const defaultTextBlock = 12.0;
  static const defaultSkeleton = 14.0;
  static const defaultModal = 32.0;
  const AcademyRadii({
    this.button = defaultButton,
    this.pillButton = defaultPillButton,
    this.field = defaultField,
    this.search = defaultSearch,
    double? surface,
    double? table,
    this.tableBadge = defaultTableBadge,
    this.rowIcon = defaultRowIcon,
    this.status = defaultStatus,
    this.image = defaultImage,
    double? disclosure,
    this.stepper = defaultStepper,
    this.menuButton = defaultMenuButton,
    this.settingsButton = defaultSettingsButton,
    this.segment = defaultSegment,
    this.compactSegment = defaultCompactSegment,
    this.segmentSelection = defaultSegmentSelection,
    this.compactSegmentSelection = defaultCompactSegmentSelection,
    this.chrome = defaultChrome,
    this.chromeButton = defaultChromeButton,
    this.expandingSearch = defaultExpandingSearch,
    this.tabBar = defaultTabBar,
    this.tabSelection = defaultTabSelection,
    this.toast = defaultToast,
    this.progress = defaultProgress,
    this.textBlock = defaultTextBlock,
    this.skeleton = defaultSkeleton,
    this.modal = defaultModal,
  }) : surface = surface ?? defaultSurface,
       table = table ?? defaultTable,
       disclosure = disclosure ?? defaultDisclosure,
       assert(pillButton >= 0 && pillButton < double.infinity),
       assert(button >= 0 && button < double.infinity),
       assert(field >= 0 && field < double.infinity),
       assert(search >= 0 && search < double.infinity),
       assert(surface == null || (surface >= 0 && surface < double.infinity)),
       assert(table == null || (table >= 0 && table < double.infinity)),
       assert(tableBadge >= 0 && tableBadge < double.infinity),
       assert(rowIcon >= 0 && rowIcon < double.infinity),
       assert(status >= 0 && status < double.infinity),
       assert(image >= 0 && image < double.infinity),
       assert(
         disclosure == null ||
             (disclosure >= 0 && disclosure < double.infinity),
       ),
       assert(stepper >= 0 && stepper < double.infinity),
       assert(menuButton >= 0 && menuButton < double.infinity),
       assert(settingsButton >= 0 && settingsButton < double.infinity),
       assert(segment >= 0 && segment < double.infinity),
       assert(compactSegment >= 0 && compactSegment < double.infinity),
       assert(segmentSelection >= 0 && segmentSelection < double.infinity),
       assert(
         compactSegmentSelection >= 0 &&
             compactSegmentSelection < double.infinity,
       ),
       assert(chrome >= 0 && chrome < double.infinity),
       assert(chromeButton >= 0 && chromeButton < double.infinity),
       assert(expandingSearch >= 0 && expandingSearch < double.infinity),
       assert(tabBar >= 0 && tabBar < double.infinity),
       assert(tabSelection >= 0 && tabSelection < double.infinity),
       assert(toast >= 0 && toast < double.infinity),
       assert(progress >= 0 && progress < double.infinity),
       assert(modal >= 0 && modal < double.infinity);
  final double button;
  final double pillButton;
  final double field;
  final double search;

  final double surface;
  final double table;
  final double tableBadge;
  final double rowIcon;
  final double status;
  final double image;

  final double disclosure;
  final double stepper;
  final double menuButton;
  final double settingsButton;
  final double segment;
  final double compactSegment;
  final double segmentSelection;
  final double compactSegmentSelection;
  final double chrome;
  final double chromeButton;
  final double expandingSearch;
  final double tabBar;
  final double tabSelection;
  final double toast;
  final double progress;
  final double textBlock;
  final double skeleton;
  final double modal;

  double value(AcademyRadiusRole role) => switch (role) {
    AcademyRadiusRole.button => button,
    AcademyRadiusRole.pillButton => pillButton,
    AcademyRadiusRole.field => field,
    AcademyRadiusRole.search => search,
    AcademyRadiusRole.surface => surface,
    AcademyRadiusRole.table => table,
    AcademyRadiusRole.tableBadge => tableBadge,
    AcademyRadiusRole.rowIcon => rowIcon,
    AcademyRadiusRole.status => status,
    AcademyRadiusRole.image => image,
    AcademyRadiusRole.disclosure => disclosure,
    AcademyRadiusRole.stepper => stepper,
    AcademyRadiusRole.menuButton => menuButton,
    AcademyRadiusRole.settingsButton => settingsButton,
    AcademyRadiusRole.segment => segment,
    AcademyRadiusRole.compactSegment => compactSegment,
    AcademyRadiusRole.segmentSelection => segmentSelection,
    AcademyRadiusRole.compactSegmentSelection => compactSegmentSelection,
    AcademyRadiusRole.chrome => chrome,
    AcademyRadiusRole.chromeButton => chromeButton,
    AcademyRadiusRole.expandingSearch => expandingSearch,
    AcademyRadiusRole.tabBar => tabBar,
    AcademyRadiusRole.tabSelection => tabSelection,
    AcademyRadiusRole.toast => toast,
    AcademyRadiusRole.progress => progress,
    AcademyRadiusRole.textBlock => textBlock,
    AcademyRadiusRole.skeleton => skeleton,
    AcademyRadiusRole.modal => modal,
  };

  AcademyRadii copyWith({
    double? button,
    double? pillButton,
    double? field,
    double? search,
    double? surface,
    double? table,
    double? tableBadge,
    double? rowIcon,
    double? status,
    double? image,
    double? disclosure,
    double? stepper,
    double? menuButton,
    double? settingsButton,
    double? segment,
    double? compactSegment,
    double? segmentSelection,
    double? compactSegmentSelection,
    double? chrome,
    double? chromeButton,
    double? expandingSearch,
    double? tabBar,
    double? tabSelection,
    double? toast,
    double? progress,
    double? textBlock,
    double? skeleton,
    double? modal,
  }) => AcademyRadii(
    button: button ?? this.button,
    pillButton: pillButton ?? this.pillButton,
    field: field ?? this.field,
    search: search ?? this.search,
    table: table ?? this.table,
    surface: surface ?? this.surface,
    disclosure: disclosure ?? this.disclosure,
    tableBadge: tableBadge ?? this.tableBadge,
    rowIcon: rowIcon ?? this.rowIcon,
    status: status ?? this.status,
    image: image ?? this.image,
    stepper: stepper ?? this.stepper,
    menuButton: menuButton ?? this.menuButton,
    settingsButton: settingsButton ?? this.settingsButton,
    segment: segment ?? this.segment,
    compactSegment: compactSegment ?? this.compactSegment,
    segmentSelection: segmentSelection ?? this.segmentSelection,
    compactSegmentSelection:
        compactSegmentSelection ?? this.compactSegmentSelection,
    chrome: chrome ?? this.chrome,
    chromeButton: chromeButton ?? this.chromeButton,
    expandingSearch: expandingSearch ?? this.expandingSearch,
    tabBar: tabBar ?? this.tabBar,
    tabSelection: tabSelection ?? this.tabSelection,
    toast: toast ?? this.toast,
    progress: progress ?? this.progress,
    textBlock: textBlock ?? this.textBlock,
    skeleton: skeleton ?? this.skeleton,
    modal: modal ?? this.modal,
  );

  AcademyRadii withValue(AcademyRadiusRole role, double value) =>
      switch (role) {
        AcademyRadiusRole.button => copyWith(button: value),
        AcademyRadiusRole.pillButton => copyWith(pillButton: value),
        AcademyRadiusRole.field => copyWith(field: value),
        AcademyRadiusRole.search => copyWith(search: value),
        AcademyRadiusRole.surface => copyWith(surface: value),
        AcademyRadiusRole.table => copyWith(table: value),
        AcademyRadiusRole.tableBadge => copyWith(tableBadge: value),
        AcademyRadiusRole.rowIcon => copyWith(rowIcon: value),
        AcademyRadiusRole.status => copyWith(status: value),
        AcademyRadiusRole.image => copyWith(image: value),
        AcademyRadiusRole.disclosure => copyWith(disclosure: value),
        AcademyRadiusRole.stepper => copyWith(stepper: value),
        AcademyRadiusRole.menuButton => copyWith(menuButton: value),
        AcademyRadiusRole.settingsButton => copyWith(settingsButton: value),
        AcademyRadiusRole.segment => copyWith(segment: value),
        AcademyRadiusRole.compactSegment => copyWith(compactSegment: value),
        AcademyRadiusRole.segmentSelection => copyWith(segmentSelection: value),
        AcademyRadiusRole.compactSegmentSelection => copyWith(
          compactSegmentSelection: value,
        ),
        AcademyRadiusRole.chrome => copyWith(chrome: value),
        AcademyRadiusRole.chromeButton => copyWith(chromeButton: value),
        AcademyRadiusRole.expandingSearch => copyWith(expandingSearch: value),
        AcademyRadiusRole.tabBar => copyWith(tabBar: value),
        AcademyRadiusRole.tabSelection => copyWith(tabSelection: value),
        AcademyRadiusRole.toast => copyWith(toast: value),
        AcademyRadiusRole.progress => copyWith(progress: value),
        AcademyRadiusRole.textBlock => copyWith(textBlock: value),
        AcademyRadiusRole.skeleton => copyWith(skeleton: value),
        AcademyRadiusRole.modal => copyWith(modal: value),
      };
}
