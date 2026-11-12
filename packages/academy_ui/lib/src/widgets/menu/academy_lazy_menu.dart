import 'package:cupertino_ui/cupertino_ui.dart';

import 'academy_menu_anchor.dart';

/// A menu anchor that exists only while the menu is open.
///
/// A live anchor keeps a ticker, a focus scope and a controller at rest and
/// rescans its children on dependency changes. That is wasteful for per-item
/// context menus that appear many times at once, so this renders only [builder]
/// until activated, opens a real anchor on the next frame and unmounts it once
/// the close animation has finished. At most one such menu is open at a time.
class AcademyLazyMenu extends StatefulWidget {
  const AcademyLazyMenu({
    super.key,
    required this.items,
    required this.builder,
    this.consumeOutsideTaps = true,
    this.useRootOverlay,
  });

  /// Built only when the menu opens.
  final List<Widget> Function(BuildContext context) items;

  /// Builds the trigger; the callback opens the menu, or closes an open one.
  final Widget Function(BuildContext context, VoidCallback toggle, bool isOpen)
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
  State<AcademyLazyMenu> createState() => _AcademyLazyMenuState();
}

class _AcademyLazyMenuState extends State<AcademyLazyMenu> {
  final MenuController _controller = MenuController();
  bool _open = false;
  bool _pendingOpen = false;

  void _toggle() {
    if (_open) {
      _controller.close();
      return;
    }
    AcademyLazyMenu.closeOpenMenus(except: _controller);
    setState(() {
      _open = true;
      _pendingOpen = true;
    });
  }

  @override
  void dispose() {
    AcademyLazyMenu._openControllers.remove(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) return widget.builder(context, _toggle, false);
    if (_pendingOpen) {
      _pendingOpen = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _open && !_controller.isOpen) _controller.open();
      });
    }
    return AcademyMenuAnchor(
      controller: _controller,
      consumeOutsideTaps: widget.consumeOutsideTaps,
      useRootOverlay: widget.useRootOverlay,
      onOpen: () => AcademyLazyMenu._openControllers.add(_controller),
      // Fires after the close animation, so unmounting does not cut it short.
      onClose: () {
        AcademyLazyMenu._openControllers.remove(_controller);
        if (mounted) setState(() => _open = false);
      },
      menuChildren: widget.items(context),
      builder: (context, controller, child) =>
          widget.builder(context, _toggle, true),
    );
  }
}
