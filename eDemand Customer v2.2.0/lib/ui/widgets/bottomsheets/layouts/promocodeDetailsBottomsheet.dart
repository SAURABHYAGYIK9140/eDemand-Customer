import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class PromocodeDetailsBottomSheet extends StatelessWidget {
  final Promocode promocodeDetails;

  const PromocodeDetailsBottomSheet({
    super.key,
    required this.promocodeDetails,
  });

  //
  Widget getMessageContainer({required final String message, required int delay}) =>
      AnimationFromBottomSide(
        delay: delay,
        child: Row(
          children: [
            const Icon(Icons.remove, size: 10),
            const CustomSizedBox(
              width: 5,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: CustomText(
                  message,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),

        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: borderRadiusOf10,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadiusOf10),
                child: CustomCachedNetworkImage(
                  networkImageUrl: promocodeDetails.image!,
                  height: 50,
                  width: 50,
                  fit: BoxFit.fill,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      promocodeDetails.promoCode!,

                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.bold,

                      maxLines: 1,

                    ),
                    CustomText(
                      promocodeDetails.message!,

                        color: Theme.of(context).colorScheme.lightGreyColor,
                        fontSize: 12,


                      maxLines: 2,
                    ),
                    /*  Row(
                      children: [
                        CustomText(
                          '${promocodeDetails.discount!} '
                          '${promocodeDetails.discountType}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        CustomText(' ${"off".translate(context: context)}')
                      ],
                    ),*/
                  ],
                ),
              ),
            ],
          ),
          const CustomSizedBox(height: 10),
          getMessageContainer(message: promocodeDetails.message!, delay: 50),
          getMessageContainer(
            message:
                "${'offerIsApplicableOnMinimumValueOf'.translate(context: context)} ${promocodeDetails.minimumOrderAmount!.priceFormat()}",
            delay: 60,
          ),
          getMessageContainer(
            message:
                "${'maximumInstantDiscountOf'.translate(context: context)} ${promocodeDetails.maxDiscountAmount!.priceFormat()}",
            delay: 70,
          ),
          getMessageContainer(
            message:
                "${'offerValidFrom'.translate(context: context)} ${promocodeDetails.startDate.toString().formatDate()} ${'to'.translate(context: context)} ${promocodeDetails.endDate.toString().formatDate()}",
            delay: 80,
          ),
          if (int.parse(promocodeDetails.noOfRepeatUsage!) > 1)
            getMessageContainer(
              message:
                  "${"applicableMaximum".translate(context: context)} ${promocodeDetails.noOfRepeatUsage} ${"timesDuringCampaignPeriod".translate(context: context)}",
              delay: 90,
            ),
          if (int.parse(promocodeDetails.noOfRepeatUsage!) == 1)
            getMessageContainer(
              message: 'offerValidOncePerCustomerDuringCampaignPeriod'.translate(context: context),
              delay: 100,
            ),
        ],
      ),
    );
  }
}
