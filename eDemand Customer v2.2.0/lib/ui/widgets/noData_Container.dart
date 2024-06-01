import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class NoDataContainer extends StatelessWidget {
  final Color? textColor;
  final String titleKey;
  final Function? onTapRetry;
  final bool? showRetryButton;
  final Color? retryButtonBackgroundColor;
  final Color? retryButtonTextColor;
  final String? buttonName;


  const NoDataContainer(
      {required this.titleKey,
      final Key? key,
      this.textColor,
      this.onTapRetry,
      this.showRetryButton,
      this.retryButtonBackgroundColor,
      this.retryButtonTextColor, this.buttonName})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSizedBox(
              height: MediaQuery.sizeOf(context).height * (0.35),
              child: CustomSvgPicture(svgImage: 'no_data_found'),
            ),
            CustomSizedBox(
              height: MediaQuery.sizeOf(context).height * (0.025),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomText(
                titleKey,
                textAlign: TextAlign.center,

                  color: textColor ?? Theme.of(context).colorScheme.blackColor,
                  fontSize: 16,

              ),
            ),
            const CustomSizedBox(
              height: 15,
            ),
            if (showRetryButton ?? false)
              CustomRoundedButton(
                height: 40,
                widthPercentage: 0.3,
                backgroundColor:
                    retryButtonBackgroundColor ?? Theme.of(context).colorScheme.accentColor,
                onTap: () {
                  onTapRetry?.call();
                },
                titleColor: retryButtonTextColor ?? AppColors.whiteColors,
                buttonTitle: (buttonName ?? 'retry').translate(context: context),
                showBorder: false,
              )
          ],
        ),
      );
}
