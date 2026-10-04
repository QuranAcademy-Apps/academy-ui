import 'package:flutter/cupertino.dart';

enum AcademyPaddingRole {
  button,
  pillButton,
  textButton,
  fieldOuter,
  field,
  search,
  searchPrefix,
  searchLoading,
  surface,
  status,
  feedback,
  feedbackIcon,
  feedbackCard,
  tableBadge,
  tableHeader,
  tableFooter,
  tableBody,
  tableRow,
  rowSubtitle,
  divider,
  disclosureHeader,
  disclosureBody,
  menuButton,
  menuOverlay,
  chromeMenu,
  chromeCapsule,
  chromeBar,
  chromeBottom,
  expandingSearch,
  tabBar,
  compactTabBar,
  toast,
  toastWithIcons,
  modal,
  modalContent,
  landscapeModal,
  groupedTable,
}

/// Immutable component defaults. Explicit widget overrides take precedence.
@immutable
class AcademyPaddings {
  const AcademyPaddings({
    this.pillButton = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.button = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.textButton = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.fieldOuter = const EdgeInsets.symmetric(vertical: 10),
    this.field = const EdgeInsets.all(12),
    this.search = const EdgeInsets.all(12),
    this.searchPrefix = const EdgeInsets.only(left: 12),
    this.searchLoading = const EdgeInsets.all(12),
    this.surface = const EdgeInsets.all(20),
    this.status = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.feedback = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    this.feedbackIcon = const EdgeInsets.all(10),
    this.feedbackCard = const EdgeInsets.all(24),
    this.tableBadge = const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    this.tableHeader = const EdgeInsets.fromLTRB(16, 0, 16, 8),
    this.tableFooter = const EdgeInsets.fromLTRB(12, 8, 12, 0),
    this.tableBody = EdgeInsets.zero,
    this.tableRow = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.rowSubtitle = const EdgeInsets.only(top: 2),
    this.divider = const EdgeInsets.symmetric(vertical: 8),
    this.disclosureHeader = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.disclosureBody = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.menuButton = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.menuOverlay = const EdgeInsets.all(8),
    this.chromeMenu = const EdgeInsets.symmetric(horizontal: 14),
    this.chromeCapsule = const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 12,
    ),
    this.chromeBar = const EdgeInsets.symmetric(horizontal: 16),
    this.chromeBottom = const EdgeInsets.symmetric(vertical: 8),
    this.expandingSearch = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.tabBar = const EdgeInsets.all(6),
    this.compactTabBar = const EdgeInsets.all(4),
    this.toast = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.toastWithIcons = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.modal = const EdgeInsets.fromLTRB(24, 8, 24, 24),
    this.modalContent = const EdgeInsets.all(24),
    this.landscapeModal = const EdgeInsets.symmetric(horizontal: 16),
    this.groupedTable = const EdgeInsets.all(0),
  });
  final EdgeInsets button;
  final EdgeInsets pillButton;
  final EdgeInsets textButton;
  final EdgeInsets fieldOuter;
  final EdgeInsets field;
  final EdgeInsets search;
  final EdgeInsets searchPrefix;
  final EdgeInsets searchLoading;
  final EdgeInsets surface;
  final EdgeInsets status;
  final EdgeInsets feedback;
  final EdgeInsets feedbackIcon;
  final EdgeInsets feedbackCard;
  final EdgeInsets tableBadge;
  final EdgeInsets tableHeader;
  final EdgeInsets tableFooter;
  final EdgeInsets tableBody;
  final EdgeInsets tableRow;
  final EdgeInsets rowSubtitle;
  final EdgeInsets divider;
  final EdgeInsets disclosureHeader;
  final EdgeInsets disclosureBody;
  final EdgeInsets menuButton;
  final EdgeInsets menuOverlay;
  final EdgeInsets chromeMenu;
  final EdgeInsets chromeCapsule;
  final EdgeInsets chromeBar;
  final EdgeInsets chromeBottom;
  final EdgeInsets expandingSearch;
  final EdgeInsets tabBar;
  final EdgeInsets compactTabBar;
  final EdgeInsets toast;
  final EdgeInsets toastWithIcons;
  final EdgeInsets modal;
  final EdgeInsets modalContent;
  final EdgeInsets landscapeModal;
  final EdgeInsets groupedTable;

  EdgeInsets value(AcademyPaddingRole role) => switch (role) {
    AcademyPaddingRole.button => button,
    AcademyPaddingRole.pillButton => pillButton,
    AcademyPaddingRole.textButton => textButton,
    AcademyPaddingRole.fieldOuter => fieldOuter,
    AcademyPaddingRole.field => field,
    AcademyPaddingRole.search => search,
    AcademyPaddingRole.searchPrefix => searchPrefix,
    AcademyPaddingRole.searchLoading => searchLoading,
    AcademyPaddingRole.surface => surface,
    AcademyPaddingRole.status => status,
    AcademyPaddingRole.feedback => feedback,
    AcademyPaddingRole.feedbackIcon => feedbackIcon,
    AcademyPaddingRole.feedbackCard => feedbackCard,
    AcademyPaddingRole.tableBadge => tableBadge,
    AcademyPaddingRole.tableHeader => tableHeader,
    AcademyPaddingRole.tableFooter => tableFooter,
    AcademyPaddingRole.tableBody => tableBody,
    AcademyPaddingRole.tableRow => tableRow,
    AcademyPaddingRole.rowSubtitle => rowSubtitle,
    AcademyPaddingRole.divider => divider,
    AcademyPaddingRole.disclosureHeader => disclosureHeader,
    AcademyPaddingRole.disclosureBody => disclosureBody,
    AcademyPaddingRole.menuButton => menuButton,
    AcademyPaddingRole.menuOverlay => menuOverlay,
    AcademyPaddingRole.chromeMenu => chromeMenu,
    AcademyPaddingRole.chromeCapsule => chromeCapsule,
    AcademyPaddingRole.chromeBar => chromeBar,
    AcademyPaddingRole.chromeBottom => chromeBottom,
    AcademyPaddingRole.expandingSearch => expandingSearch,
    AcademyPaddingRole.tabBar => tabBar,
    AcademyPaddingRole.compactTabBar => compactTabBar,
    AcademyPaddingRole.toast => toast,
    AcademyPaddingRole.toastWithIcons => toastWithIcons,
    AcademyPaddingRole.modal => modal,
    AcademyPaddingRole.modalContent => modalContent,
    AcademyPaddingRole.landscapeModal => landscapeModal,
    AcademyPaddingRole.groupedTable => groupedTable,
  };

  AcademyPaddings copyWith({
    EdgeInsets? button,
    EdgeInsets? pillButton,
    EdgeInsets? textButton,
    EdgeInsets? fieldOuter,
    EdgeInsets? field,
    EdgeInsets? search,
    EdgeInsets? searchPrefix,
    EdgeInsets? searchLoading,
    EdgeInsets? surface,
    EdgeInsets? status,
    EdgeInsets? feedback,
    EdgeInsets? feedbackIcon,
    EdgeInsets? feedbackCard,
    EdgeInsets? tableBadge,
    EdgeInsets? tableHeader,
    EdgeInsets? tableFooter,
    EdgeInsets? tableBody,
    EdgeInsets? tableRow,
    EdgeInsets? rowSubtitle,
    EdgeInsets? divider,
    EdgeInsets? disclosureHeader,
    EdgeInsets? disclosureBody,
    EdgeInsets? menuButton,
    EdgeInsets? menuOverlay,
    EdgeInsets? chromeMenu,
    EdgeInsets? chromeCapsule,
    EdgeInsets? chromeBar,
    EdgeInsets? chromeBottom,
    EdgeInsets? expandingSearch,
    EdgeInsets? tabBar,
    EdgeInsets? compactTabBar,
    EdgeInsets? toast,
    EdgeInsets? toastWithIcons,
    EdgeInsets? modal,
    EdgeInsets? modalContent,
    EdgeInsets? landscapeModal,
    EdgeInsets? groupedTable,
  }) => AcademyPaddings(
    button: button ?? this.button,
    pillButton: pillButton ?? this.pillButton,
    textButton: textButton ?? this.textButton,
    fieldOuter: fieldOuter ?? this.fieldOuter,
    field: field ?? this.field,
    search: search ?? this.search,
    searchPrefix: searchPrefix ?? this.searchPrefix,
    searchLoading: searchLoading ?? this.searchLoading,
    surface: surface ?? this.surface,
    status: status ?? this.status,
    feedback: feedback ?? this.feedback,
    feedbackIcon: feedbackIcon ?? this.feedbackIcon,
    feedbackCard: feedbackCard ?? this.feedbackCard,
    tableBadge: tableBadge ?? this.tableBadge,
    tableHeader: tableHeader ?? this.tableHeader,
    tableFooter: tableFooter ?? this.tableFooter,
    tableBody: tableBody ?? this.tableBody,
    tableRow: tableRow ?? this.tableRow,
    rowSubtitle: rowSubtitle ?? this.rowSubtitle,
    divider: divider ?? this.divider,
    disclosureHeader: disclosureHeader ?? this.disclosureHeader,
    disclosureBody: disclosureBody ?? this.disclosureBody,
    menuButton: menuButton ?? this.menuButton,
    menuOverlay: menuOverlay ?? this.menuOverlay,
    chromeMenu: chromeMenu ?? this.chromeMenu,
    chromeCapsule: chromeCapsule ?? this.chromeCapsule,
    chromeBar: chromeBar ?? this.chromeBar,
    chromeBottom: chromeBottom ?? this.chromeBottom,
    expandingSearch: expandingSearch ?? this.expandingSearch,
    tabBar: tabBar ?? this.tabBar,
    compactTabBar: compactTabBar ?? this.compactTabBar,
    toast: toast ?? this.toast,
    toastWithIcons: toastWithIcons ?? this.toastWithIcons,
    modal: modal ?? this.modal,
    modalContent: modalContent ?? this.modalContent,
    landscapeModal: landscapeModal ?? this.landscapeModal,
    groupedTable: groupedTable ?? this.groupedTable,
  );

  AcademyPaddings withValue(AcademyPaddingRole role, EdgeInsets value) =>
      switch (role) {
        AcademyPaddingRole.button => copyWith(button: value),
        AcademyPaddingRole.pillButton => copyWith(pillButton: value),
        AcademyPaddingRole.textButton => copyWith(textButton: value),
        AcademyPaddingRole.fieldOuter => copyWith(fieldOuter: value),
        AcademyPaddingRole.field => copyWith(field: value),
        AcademyPaddingRole.search => copyWith(search: value),
        AcademyPaddingRole.searchPrefix => copyWith(searchPrefix: value),
        AcademyPaddingRole.searchLoading => copyWith(searchLoading: value),
        AcademyPaddingRole.surface => copyWith(surface: value),
        AcademyPaddingRole.status => copyWith(status: value),
        AcademyPaddingRole.feedback => copyWith(feedback: value),
        AcademyPaddingRole.feedbackIcon => copyWith(feedbackIcon: value),
        AcademyPaddingRole.feedbackCard => copyWith(feedbackCard: value),
        AcademyPaddingRole.tableBadge => copyWith(tableBadge: value),
        AcademyPaddingRole.tableHeader => copyWith(tableHeader: value),
        AcademyPaddingRole.tableFooter => copyWith(tableFooter: value),
        AcademyPaddingRole.tableBody => copyWith(tableBody: value),
        AcademyPaddingRole.tableRow => copyWith(tableRow: value),
        AcademyPaddingRole.rowSubtitle => copyWith(rowSubtitle: value),
        AcademyPaddingRole.divider => copyWith(divider: value),
        AcademyPaddingRole.disclosureHeader => copyWith(
          disclosureHeader: value,
        ),
        AcademyPaddingRole.disclosureBody => copyWith(disclosureBody: value),
        AcademyPaddingRole.menuButton => copyWith(menuButton: value),
        AcademyPaddingRole.menuOverlay => copyWith(menuOverlay: value),
        AcademyPaddingRole.chromeMenu => copyWith(chromeMenu: value),
        AcademyPaddingRole.chromeCapsule => copyWith(chromeCapsule: value),
        AcademyPaddingRole.chromeBar => copyWith(chromeBar: value),
        AcademyPaddingRole.chromeBottom => copyWith(chromeBottom: value),
        AcademyPaddingRole.expandingSearch => copyWith(expandingSearch: value),
        AcademyPaddingRole.tabBar => copyWith(tabBar: value),
        AcademyPaddingRole.compactTabBar => copyWith(compactTabBar: value),
        AcademyPaddingRole.toast => copyWith(toast: value),
        AcademyPaddingRole.toastWithIcons => copyWith(toastWithIcons: value),
        AcademyPaddingRole.modal => copyWith(modal: value),
        AcademyPaddingRole.modalContent => copyWith(modalContent: value),
        AcademyPaddingRole.landscapeModal => copyWith(landscapeModal: value),
        AcademyPaddingRole.groupedTable => copyWith(groupedTable: value),
      };
}
