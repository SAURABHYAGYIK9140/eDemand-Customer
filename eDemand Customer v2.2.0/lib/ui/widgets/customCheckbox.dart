
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({super.key, required this.onChanged, this.value});

  final Function(bool?) onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      activeColor: Theme.of(context).colorScheme.accentColor,
      fillColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.primaryColor,
      ),
      side: MaterialStateBorderSide.resolveWith(
        (states) => BorderSide(width: 1.0, color: Theme.of(context).colorScheme.accentColor),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusOf5)),
      visualDensity: VisualDensity.standard,
      checkColor: Theme.of(context).colorScheme.accentColor,
      value: value,
      onChanged: (bool? val) {
        onChanged.call(val);
      },
    );
  }
}
