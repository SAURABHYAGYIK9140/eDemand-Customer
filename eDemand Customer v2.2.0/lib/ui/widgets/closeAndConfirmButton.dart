import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CloseAndConfirmButton extends StatelessWidget {
  final String? confirmButtonName;
  final String? closeButtonName;
  final Color? confirmButtonBackgroundColor;
  final Color? closeButtonBackgroundColor;

  ///default it will be false
  final bool? showProgressIndicator;
  final Function closeButtonPressed;
  final Function confirmButtonPressed;
  final Widget? confirmButtonChild;

  const CloseAndConfirmButton(
      {super.key,
      this.confirmButtonName,
      this.closeButtonName,
      this.confirmButtonBackgroundColor,
      this.closeButtonBackgroundColor,
      this.showProgressIndicator,
      required this.closeButtonPressed,
      required this.confirmButtonPressed,
      this.confirmButtonChild});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Expanded(
            child: CustomInkWellContainer(
              onTap: () {
                closeButtonPressed.call();
              },
              child: CustomContainer(
                height: 44,
                borderRadiusStyle: const BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(borderRadiusOf10)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  )
                ],
                color: closeButtonBackgroundColor ?? Theme.of(context).colorScheme.secondaryColor,
                child: Center(
                  child: CustomText(
                    (closeButtonName ?? "close").translate(context: context),
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomInkWellContainer(
              onTap: () {
                confirmButtonPressed.call();
              },
              child: CustomContainer(
                height: 44,
                borderRadiusStyle: const BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(borderRadiusOf10)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  )
                ],
                color: confirmButtonBackgroundColor ?? Theme.of(context).colorScheme.accentColor,
                child: Center(
                  child: showProgressIndicator ?? false
                      ? showCircularProgressIndicator(context: context)
                      : confirmButtonChild ??
                          CustomText(
                            (confirmButtonName ?? "confirm").translate(context: context),
                            color: AppColors.whiteColors,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget showCircularProgressIndicator({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: CustomSizedBox(
        height: 30,
        width: 25,
        child: CustomCircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondaryColor,
        ),
      ),
    );
  }
}
