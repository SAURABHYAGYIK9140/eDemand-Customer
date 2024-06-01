import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderListItem extends StatelessWidget {
  const ProviderListItem({final Key? key, this.providerDetails, this.categoryId}) : super(key: key);
  final Providers? providerDetails;
  final String? categoryId;

  Widget _getVisitingChargeContainer(
          {required final BuildContext context, final String? visitingCharge}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'visitingCharge'.translate(context: context),

              color: Theme.of(context).colorScheme.lightGreyColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 12,

          ),
          const CustomSizedBox(
            height: 5,
          ),
          CustomText(
            visitingCharge!.priceFormat(),

              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 10,

          ),
        ],
      );

  Widget _getRatingContainer(final BuildContext context, {final String? providerRating}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'rating'.translate(context: context),

              color: Theme.of(context).colorScheme.lightGreyColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 12,

          ),
          const CustomSizedBox(
            height: 5,
          ),
          Row(
            children: [
               Icon(Icons.star, color: AppColors.ratingStarColor, size: 15),
              CustomText(
                providerRating!,

                  color: Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 10,

              ),
            ],
          )
        ],
      );

  Widget _getProviderName({
    required final BuildContext context,
    required final String providerName,
    required final bool isProviderAvailableCurrently,
  }) =>
      CustomText(
        providerName,

          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 12,

        textAlign: TextAlign.left,
      );

  Widget _getProviderCompanyName({
    required final BuildContext context,
    required final String companyName,
    required final bool isProviderAvailableCurrently,
  }) =>
      CustomText(
        companyName,

          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.normal,
          fontSize: 16,

        textAlign: TextAlign.left,
      );

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
    child: CustomContainer(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Stack(
        children: [
          CustomContainer(

              color: Theme.of(context).colorScheme.secondaryColor,
              borderRadius: borderRadiusOf10,

            child: Row(

              children: [
                CustomImageContainer(
                  width: 90,
                  height: 110,
                  borderRadius: borderRadiusOf10,
                  imageURL: providerDetails!.image!,
                  boxFit: BoxFit.fill,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _getProviderName(
                          context: context,
                          providerName: providerDetails!.partnerName!,
                          isProviderAvailableCurrently: providerDetails!.isAvailableNow!,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: _getProviderCompanyName(
                            context: context,
                            companyName: providerDetails!.companyName!,
                            isProviderAvailableCurrently: providerDetails!.isAvailableNow!,
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: _getRatingContainer(
                                context,
                                providerRating: providerDetails!.ratings,
                              ),
                            ),
                            const CustomSizedBox(
                              width: 20,
                            ),
                            _getVisitingChargeContainer(
                              context: context,
                              visitingCharge: providerDetails!.visitingCharge,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          PositionedDirectional(
            top: 12,
            end: 15,
            child: BookMarkIcon(
              providerData: providerDetails!,
            ),
          ),
        ],
      ),
    ),
    onTap: () {
      Navigator.pushNamed(
        context,
        providerRoute,
        arguments: {'providers': providerDetails, 'providerId': providerDetails!.providerId},
      );
    },
  );
}
