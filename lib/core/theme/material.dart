import "dart:ui";
import "package:flutter/material.dart";

import "../../constants.dart";
import "colors.dart";

enum MyMaterialTheme { solid, glass, border }

class MyMaterial extends StatelessWidget {
  const MyMaterial({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(kCircleBorderRadius),
    ),
    this.blurStrength = 2,
    this.height,
    this.width,
    this.whiteBG = true,
    this.theme = MyMaterialTheme.solid,
    this.hasShadow = true,
    this.hasBorder = true,
    this.bg,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius borderRadius;
  final double blurStrength;
  final double? height;
  final double? width;
  final bool whiteBG;
  final MyMaterialTheme theme;
  final bool hasShadow;
  final bool hasBorder;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final bool isGlass = theme == MyMaterialTheme.glass;

    if (theme == MyMaterialTheme.border) {
      return Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: kSmallPadding),
        decoration: BoxDecoration(
          color: context.secondary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.secondary.withOpacity(0.1)),
        ),
        child: child,
      );
    }

    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: bg != null ? null : _buildGradient(context, isGlass),
      color: bg,
      border: hasBorder ? _buildBorder(context) : null,
      boxShadow: (hasShadow && !isGlass)
          ? [
              BoxShadow(
                color: context.shadow,
                blurRadius: 10,
                blurStyle: BlurStyle.outer,
              ),
            ]
          : null,
    );

    Widget current = AnimatedContainer(
      duration: kAnimationDuration,
      curve: kCurveEaseInOut,
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      decoration: decoration,
      child: AnimatedSize(
        duration: kAnimationDuration,
        curve: Curves.easeInOut,
        child: child,
      ),
    );

    if (isGlass) {
      current = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: current,
        ),
      );
    }

    return RepaintBoundary(
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(color: isGlass ? AppColors.foreground : context.text),
        child: IconTheme(
          data: IconThemeData(
            color: isGlass ? AppColors.foreground : context.text,
          ),
          child: current,
        ),
      ),
    );
  }

  Gradient _buildGradient(BuildContext context, bool isGlass) {
    final baseColor = isGlass ? context.foreground : context.background;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(isGlass ? 0.1 : 0.9),
        baseColor.withOpacity(isGlass ? 0 : 1),
        baseColor.withOpacity(isGlass ? 0.1 : 0.9),
      ],
    );
  }

  Border _buildBorder(BuildContext context) {
    final side = BorderSide(color: context.border, width: 0.7);
    final bool isTall = height != null && height! > 100;

    return Border(
      top: side,
      bottom: side,
      left: isTall ? side.copyWith(width: 0.3) : BorderSide.none,
      right: isTall ? side.copyWith(width: 0.3) : BorderSide.none,
    );
  }
}
