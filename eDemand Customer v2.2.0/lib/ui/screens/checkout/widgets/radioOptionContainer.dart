import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class RadioOptionContainer extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  final String value;
  final String groupValue;
  final int index;
  final Function(Object?)? onChanged;

  const RadioOptionContainer(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      required this.value,
      required this.groupValue,
      this.onChanged,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      enableFeedback: true,
      controlAffinity: ListTileControlAffinity.trailing,
      visualDensity: VisualDensity.compact,
      tileColor: Theme.of(context).colorScheme.secondaryColor,
      isThreeLine: false,
      shape: index == 0
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadiusOf10),
                  topRight: Radius.circular(borderRadiusOf10)))
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(borderRadiusOf10),
                  bottomRight: Radius.circular(borderRadiusOf10))),
      secondary: CustomSizedBox(
        height: 25,
        width: 25,
        child: CustomSvgPicture(
          svgImage: image,
          color: Theme.of(context).colorScheme.accentColor,
        ),
      ),
      title: CustomText(
        title.translate(context: context),fontSize: 14

      ),
      subtitle: CustomText(
        subTitle.translate(context: context),fontSize: 12,

        maxLines: 1,

      ),
      value: value,
      activeColor: Theme.of(context).colorScheme.accentColor,
      groupValue: groupValue,
      onChanged: (final Object? selectedValue) {
        onChanged?.call(selectedValue);
      },
    );
  }
}
