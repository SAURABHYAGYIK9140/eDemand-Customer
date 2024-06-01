import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ImageWithText extends StatelessWidget {
  const ImageWithText({
    required this.imageContainerHeight,
    required this.imageContainerWidth,
    required this.imageRadius,
    required this.textContainerHeight,
    required this.textContainerWidth,
    required this.onTap,
    required this.imageURL,
    required this.title,
    final Key? key,
    this.maxLines,
    this.fontWeight,
    this.darkModeBackgroundColor,
    this.lightModeBackgroundColor,
    this.textAlign,
  }) : super(key: key);

  //
  final String imageURL, title;
  final double imageContainerHeight,
      imageContainerWidth,
      imageRadius,
      textContainerHeight,
      textContainerWidth;
  final void Function()? onTap;
  final int? maxLines;
  final FontWeight? fontWeight;
  final String? darkModeBackgroundColor, lightModeBackgroundColor;
  final TextAlign? textAlign;

  @override
  Widget build(final BuildContext context) {
    final darkModeColor =
        darkModeBackgroundColor == "" ? Colors.transparent : darkModeBackgroundColor!.toColor();
    final lightModeColor =
        lightModeBackgroundColor == "" ? Colors.transparent : lightModeBackgroundColor!.toColor();
    return CustomInkWellContainer(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            height: imageContainerHeight,
            width: imageContainerWidth,
            shape: BoxShape.rectangle,
            color:
                Theme.of(context).brightness == Brightness.light ? lightModeColor : darkModeColor,
            borderRadius: imageRadius,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(imageRadius),
              child: CustomCachedNetworkImage(
                networkImageUrl: imageURL,
                fit: BoxFit.cover,
                height: imageContainerHeight,
                width: imageContainerWidth,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: CustomSizedBox(
              height: textContainerHeight,
              width: textContainerWidth,
              child: CustomText(
                title,
                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: fontWeight ?? FontWeight.bold,
                fontStyle: FontStyle.normal,
                fontSize: 12,
                maxLines: maxLines ?? 1,
                textAlign: textAlign ?? TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
