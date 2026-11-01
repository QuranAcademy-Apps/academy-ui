import 'package:cupertino_ui/cupertino_ui.dart';

import 'app_menu_anchor.dart';

/// A [CupertinoMenuAnchor] that instantiates its menu machinery only while the
/// menu is actually open.
///
/// A live [CupertinoMenuAnchor] keeps a [Ticker] (its open/close animation),
/// a [FocusScopeNode] and a [MenuController] alive at rest, and re-scans every
/// `menuChild` on dependency changes. That is fine for a one-per-screen menu,
/// but wasteful for per-item context menus that appear many times at once
/// (e.g. one per Mushaf ayah marker) — there it would mean dozens of idle
/// tickers/focus nodes and eager allocation of every menu's children on each
/// rebuild.
///
/// This wrapper renders only [builder] (the trigger) until it is activated.
/// On activation it mounts a real [CupertinoMenuAnchor], opens it on the next
/// frame, and unmounts it again once the close animation has finished. So at
/// most one anchor is live at a time, and [menuChildren] is built lazily — only
/// when the menu opens — mirroring the old imperative `showPullDownMenu` model.
class LazyCupertinoMenuAnchor extends StatefulWidget {
  const LazyCupertinoMenuAnchor({
    super.key,
    required this.menuChildren,
    required this.builder,
    this.consumeOutsideTaps = true,
    this.useRootOverlay,
  });

  /// Built lazily, only when the menu opens.
  final List<Widget> Function(BuildContext context) menuChildren;

  /// Builds the trigger. Invoke the passed callback to open the menu (or close
  /// it if it is already open).
  final Widget Function(
    BuildContext context,
    VoidCallback openMenu,
    bool isOpen,
  )
  builder;

  final bool consumeOutsideTaps;
  final bool? useRootOverlay;

  static final Set<MenuController> _openControllers = <MenuController>{};

  static void closeOpenMenus({MenuController? except}) {
    for (final controller in List<MenuController>.of(_openControllers)) {
      if (controller != except) controller.close();
    }
  }

  @override
  State<LazyCupertinoMenuAnchor> createState() =>
      _LazyCupertinoMenuAnchorState();
}

class _LazyCupertinoMenuAnchorState extends State<LazyCupertinoMenuAnchor> {
  final MenuController _controller = MenuController();
  bool _open = false;
  bool _pendingOpen = false;

  void _toggle() {
    if (_open) {
      _controller.close();
      return;
    }
    LazyCupertinoMenuAnchor.closeOpenMenus(except: _controller);
    setState(() {
      _open = true;
      _pendingOpen = true;
    });
  }

  @override
  void dispose() {
    LazyCupertinoMenuAnchor._openControllers.remove(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return widget.builder(context, _toggle, false);
    }
    if (_pendingOpen) {
      _pendingOpen = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _open && !_controller.isOpen) {
          _controller.open();
        }
      });
    }
    return AppMenuAnchor(
      controller: _controller,
      consumeOutsideTaps: widget.consumeOutsideTaps,
      useRootOverlay: widget.useRootOverlay,
      onOpen: () {
        LazyCupertinoMenuAnchor._openControllers.add(_controller);
      },
      // Fires after the close animation completes, so unmounting here does not
      // cut the animation short.
      onClose: () {
        LazyCupertinoMenuAnchor._openControllers.remove(_controller);
        if (mounted) setState(() => _open = false);
      },
      menuChildren: widget.menuChildren(context),
      builder: (context, controller, child) =>
          widget.builder(context, _toggle, true),
    );
  }
}
