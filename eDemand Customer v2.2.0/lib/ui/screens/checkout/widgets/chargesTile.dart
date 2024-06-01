import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class ChargesTile extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  final double fontSize;
  final bool? isBoldText;

  const ChargesTile(
      {super.key,
      required this.title1,
      required this.title2,
      required this.title3,
      required this.fontSize,
      this.isBoldText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: CustomText(
            title1, fontSize: fontSize, fontWeight: isBoldText ?? false ? FontWeight.bold : null,


            maxLines: 2,
          ),
        ),
        Expanded(
          flex: 2,
          child: CustomText(
            title2,fontSize: fontSize,


            maxLines: 2,
          ),
        ),
        Expanded(
          flex: 3,
          child: CustomText(
            title3,

            textAlign: TextAlign.end,

            maxLines: 2,   fontWeight: isBoldText ?? false ? FontWeight.bold : null, fontSize: fontSize
          ),
        )
      ],
    );
  }
}
