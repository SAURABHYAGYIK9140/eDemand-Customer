import 'package:flutter/material.dart';

class CustomSizedBox extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;

  const CustomSizedBox({super.key,  this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
