import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceDetailsCard extends StatelessWidget {
  //
  const ServiceDetailsCard({
    required this.services,
    final Key? key,
    this.onTap,
    this.showDescription,
    this.showAddButton,
    this.isProviderAvailableAtLocation,
  }) : super(key: key);
  final Services services;
  final String? isProviderAvailableAtLocation;
  final VoidCallback? onTap;
  final bool? showDescription;
  final bool? showAddButton;

  @override
  Widget build(final BuildContext context) => CustomContainer(
        margin: const EdgeInsets.symmetric(vertical: 7),
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: borderRadiusOf10,
        height: 135,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomInkWellContainer(
              onTap: onTap,
              child: CustomSizedBox(
                height: 135,
                width: 110,
                child: Stack(
                  children: [
                    Align(
                      child: CustomImageContainer(
                        height: 135,
                        width: 110,
                        borderRadius: borderRadiusOf10,
                        imageURL: services.imageOfTheService!,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: CustomContainer(
                        width: 110,
                        height: 100,
                        borderRadiusStyle: const BorderRadius.only(
                          bottomRight: Radius.circular(borderRadiusOf10),
                          bottomLeft: Radius.circular(borderRadiusOf10),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.black.withOpacity(0.75),
                          ],
                          stops: const [
                            0.0,
                            1.0,
                          ],
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          tileMode: TileMode.repeated,
                        ),
                      ),
                    ),
                    if ((services.discountedPrice) != "0")
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: CustomText(
                            /* Discount(%) = ((Original price - selling price)/Original price) * 100 */
                            "${(((double.parse(services.price.toString()) - double.parse(services.discountedPrice.toString())) / double.parse(services.price.toString())) * 100).toStringAsFixed(0)}${'percentageOff'.translate(context: context)}",
                            color: AppColors.whiteColors,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 18,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            const CustomSizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: CustomInkWellContainer(
                      onTap: onTap,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomText(
                            services.title!,
                            maxLines: 2,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.blackColor,
                          ),
                          if (showDescription ?? true)
                            CustomText(
                              '${services.description}',
                              maxLines: 2,
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.lightGreyColor,
                            ),
                          CustomText(
                            "${services.numberOfMembersRequired} ${"person".translate(context: context)} | ${services.duration} min",
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.lightGreyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  (services.priceWithTax != '' ? services.priceWithTax! : '0.0')
                                      .priceFormat(),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.blackColor,
                                ),
                                if (services.discountedPrice != '0')
                                  Expanded(
                                    child: CustomText(
                                      (services.originalPriceWithTax != ''
                                              ? services.originalPriceWithTax!
                                              : '0.0')
                                          .priceFormat(),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.lightGreyColor,
                                      showLineThrough: true,
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xfff9bd3d),
                                    size: 14,
                                  ),
                                  CustomText(
                                    ' ${double.parse(services.rating!).toStringAsFixed(1)}',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightGreyColor
                                        .withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  CustomText(
                                    ' (${services.numberOfRatings!})',
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightGreyColor
                                        .withOpacity(0.7),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      if (showAddButton ?? true)
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: MultiBlocProvider(
                            providers: [
                              BlocProvider<AddServiceIntoCartCubit>(
                                create: (final BuildContext context) =>
                                    AddServiceIntoCartCubit(CartRepository()),
                              ),
                              BlocProvider<RemoveServiceFromCartCubit>(
                                create: (final BuildContext context) =>
                                    RemoveServiceFromCartCubit(CartRepository()),
                              ),
                            ],
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 10, bottom: 5),
                              child: BlocConsumer<CartCubit, CartState>(
                                listener: (final BuildContext context, final CartState state) {
                                  if (state is CartFetchSuccess) {
                                    try {
                                      UiUtils.getVibrationEffect();
                                    } catch (_) {}
                                  }
                                },
                                builder: (final BuildContext context, final CartState state) =>
                                    AddButton(
                                  serviceId: services.id!,
                                  isProviderAvailableAtLocation: isProviderAvailableAtLocation,
                                  maximumAllowedQuantity: int.parse(services.maxQuantityAllowed!),
                                  alreadyAddedQuantity: isProviderAvailableAtLocation == "0"
                                      ? 0
                                      : int.parse(
                                          context.read<CartCubit>().getServiceCartQuantity(
                                                serviceId: services.id!,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
}
