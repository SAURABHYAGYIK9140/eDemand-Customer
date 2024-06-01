import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../app/generalImports.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    final Key? key,
    this.color,
    this.strokeWidth,
    this.widthAndHeight,
  }) : super(key: key);
  final Color? color;
  final double? strokeWidth;
  final double? widthAndHeight;

  @override
  Widget build(final BuildContext context) => Center(
        child: CustomSizedBox(
          height: widthAndHeight ?? 30,
          width: widthAndHeight ?? 30,
          child: Platform.isAndroid
              ? CircularProgressIndicator(
                  color: color ?? Theme.of(context).colorScheme.accentColor,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 1.5,
                )
              : CupertinoActivityIndicator(
                  color: color ?? Colors.transparent,
                ),
        ),
      );
}
