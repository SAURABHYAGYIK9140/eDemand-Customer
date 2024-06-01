import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.color,
    this.showLineThrough,
    this.fontWeight,
    this.fontStyle,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.height,
    this.showUnderline,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? showLineThrough;
  final bool? showUnderline;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textScaleFactor: 1,
      maxLines: maxLines ??3,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.blackColor,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          fontSize: fontSize,

          decoration: showLineThrough ?? false
              ? TextDecoration.lineThrough
              : showUnderline ?? false
                  ? TextDecoration.underline
                  : null,
          height: height),
      textAlign: textAlign,
    );
  }
}
