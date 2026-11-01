part of '../grouped_table.dart';

class AppAccessoryButton extends StatelessWidget {
  const AppAccessoryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.size,
    this.semanticLabel,
    this.semanticHint,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Size? size;
  final String? semanticLabel;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final content = AppAccessoryFrame(
      size: size ?? const Size.square(32),
      child: child,
    );

    if (onPressed == null) return content;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Semantics(
        button: true,
        enabled: true,
        label: semanticLabel,
        hint: semanticHint,
        child: content,
      ),
    );
  }
}

class AppAccessoryFrame extends StatelessWidget {
  const AppAccessoryFrame({
    super.key,
    required this.child,
    this.size = const Size.square(24),
  });

  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Center(child: child),
    );
  }
}

class AppDragHandle extends StatelessWidget {
  const AppDragHandle({super.key});

  static const double width = 54;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: colors.separator, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: width,
        child: Center(
          child: AppSfIcon(
            AcademySymbols.dragHandle,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.iconPrimary,
            semanticsLabel: QuranCompatStrings.of(context).dragHandle,
          ),
        ),
      ),
    );
  }
}
