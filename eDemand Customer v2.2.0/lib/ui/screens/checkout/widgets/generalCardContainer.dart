import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class GeneralCardContainer extends StatelessWidget {
  final String imageName;
  final String title;
  final String description;
  final bool? showEditIcon;
  final VoidCallback? onTap;

  const GeneralCardContainer(
      {super.key,
      required this.imageName,
      required this.title,
      required this.description,
      this.showEditIcon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: Ink(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: BorderRadius.circular(borderRadiusOf10),
        ),
        child: Row(
          children: [
            CustomSizedBox(
              width: 25,
              height: 25,
              child: CustomSvgPicture(
                svgImage: imageName,
                color: Theme.of(context).colorScheme.accentColor,
              ),
            ),
            const CustomSizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    title.translate(context: context),
               fontSize: 14
                  ),
                  if (description != "")
                    CustomText(
                      description.translate(context: context), fontSize: 12,
                      color: Theme.of(context).colorScheme.lightGreyColor,
                      maxLines: 2,
                    ),
                ],
              ),
            ),
            if (showEditIcon ?? false) ...[
              CustomSizedBox(
                width: 25,
                height: 25,
                child: CustomContainer(
                  width: 25,
                  height: 25,

                    borderRadius: borderRadiusOf5,
                    color: Theme.of(context).colorScheme.primaryColor,

                  child: const Icon(Icons.edit, size: 18),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
