import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.padding,
    this.margin,
    this.child,
    this.constraints,
    this.clipBehavior,
    this.alignment,
    this.border,
    this.boxShadow,
    this.borderRadiusStyle,
    this.gradient,
    this.shape,
    this.image,
  });

  final Clip? clipBehavior;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadiusStyle;
  final Gradient? gradient;
  final BoxShape? shape;
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      clipBehavior: clipBehavior ?? Clip.none,
      constraints: constraints,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
          gradient: gradient,
          shape: shape ?? BoxShape.rectangle,
          border: border,
          boxShadow: boxShadow,
          borderRadius:
              borderRadius != null ? BorderRadius.circular(borderRadius ?? 0) : borderRadiusStyle,
          color: color,
          image: image),
      child: child,
    );
  }
}
