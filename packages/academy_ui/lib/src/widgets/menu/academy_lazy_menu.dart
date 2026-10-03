import 'package:flutter/cupertino.dart';

import 'academy_menu_anchor.dart';

/// Quran lazy anchor: allocate menu only on activation, release after closing.
class AcademyLazyMenu extends StatefulWidget {
  const AcademyLazyMenu({
    super.key,
    required this.items,
    required this.builder,
  });
  final List<Widget> Function(BuildContext) items;
  final Widget Function(BuildContext, VoidCallback) builder;
  @override
  State<AcademyLazyMenu> createState() => _AcademyLazyMenuState();
}

class _AcademyLazyMenuState extends State<AcademyLazyMenu> {
  final MenuController _controller = MenuController();
  bool _active = false;
  void _open() {
    if (_active) {
      _controller.close();
      return;
    }
    setState(() => _active = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _active) _controller.open();
    });
  }

  @override
  Widget build(BuildContext context) => !_active
      ? widget.builder(context, _open)
      : AcademyMenuAnchor(
          controller: _controller,
          consumeOutsideTaps: true,
          onClose: () {
            if (mounted) setState(() => _active = false);
          },
          menuChildren: widget.items(context),
          builder: (context, controller, child) =>
              widget.builder(context, _open),
        );
}
