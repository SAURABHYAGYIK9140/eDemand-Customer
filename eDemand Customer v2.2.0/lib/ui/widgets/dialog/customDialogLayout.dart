import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomDialogLayout extends StatelessWidget {
  final String title;
  final String? description;
  final String confirmButtonName;
  final String cancelButtonName;
  final Color confirmButtonBackgroundColor;
  final Color cancelButtonBackgroundColor;

  final Function cancelButtonPressed;
  final Function confirmButtonPressed;
  final Widget? icon;
  final Widget? confirmButtonChild;

  const CustomDialogLayout(
      {final Key? key,
      required this.title,
      this.description,
      required this.confirmButtonName,
      required this.cancelButtonName,
      this.icon,
      required this.cancelButtonPressed,
      required this.confirmButtonPressed,
      required this.confirmButtonBackgroundColor,
      required this.cancelButtonBackgroundColor,
      this.confirmButtonChild})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => CustomContainer(
        height: MediaQuery.sizeOf(context).height * 0.3,
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: borderRadiusOf10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomSizedBox(
                height: MediaQuery.sizeOf(context).height * 0.3 - 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const CustomSizedBox(height: 10),
                    ],
                    CustomText(
                      title.translate(context: context),
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 16,
                    ),
                    const CustomSizedBox(height: 10),
                    if (description != null) ...[
                      const CustomSizedBox(height: 10),
                      CustomText(
                        description!.translate(context: context),
                        color: Theme.of(context).colorScheme.lightGreyColor,
                        fontSize: 12,
                        maxLines: 10,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CloseAndConfirmButton(
                  confirmButtonBackgroundColor: confirmButtonBackgroundColor,
                  confirmButtonName: confirmButtonName,
                  confirmButtonChild: confirmButtonChild,
                  showProgressIndicator: false,
                  closeButtonBackgroundColor: cancelButtonBackgroundColor,
                  closeButtonName: cancelButtonName,
                  closeButtonPressed: () {
                    cancelButtonPressed.call();
                  },
                  confirmButtonPressed: () {
                    confirmButtonPressed.call();
                  },
                ),
              ),
            )
          ],
        ),
      );
}
