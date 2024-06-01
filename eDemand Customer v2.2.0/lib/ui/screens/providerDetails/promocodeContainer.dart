import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/promocodeDetailsBottomsheet.dart';
import 'package:flutter/material.dart';

class PromocodeContainer extends StatelessWidget {
  final String providerId;

  const PromocodeContainer({super.key, required this.providerId});

  void fetchPromoCodes({
    required BuildContext context,
  }) {
    context.read<GetPromocodeCubit>().getPromocodes(providerId: providerId);
  }

  Widget promoCodeLoadingShimmer({
    required BuildContext context,
  }) =>
      Column(
        children: List.generate(
          numberOfShimmerContainer,
          (final int index) => CustomContainer(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                const CustomShimmerLoadingContainer(
                  height: 80,
                  width: 80,
                ),
                const CustomSizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerLoadingContainer(
                      height: 10,
                      width: MediaQuery.sizeOf(context).width * 0.4,
                    ),
                    const CustomSizedBox(
                      height: 10,
                    ),
                    CustomShimmerLoadingContainer(
                      height: 10,
                      width: MediaQuery.sizeOf(context).width * 0.4,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: context.read<CartCubit>().getProviderIDFromCartData() == '0'
              ? 0
              : bottomNavigationBarHeight + 10,
        ),
        child: BlocBuilder<GetPromocodeCubit, GetPromocodeState>(
          builder: (final BuildContext context, final GetPromocodeState state) {
            if (state is FetchPromocodeFailure) {
              return ErrorContainer(
                errorMessage: state.errorMessage.translate(context: context),
                onTapRetry: () {
                  fetchPromoCodes(context: context);
                },
              );
            }
            if (state is FetchPromocodeSuccess) {
              return state.promocodeList.isEmpty
                  ? Center(
                      child: NoDataContainer(
                        titleKey: 'noPromoCodeAvailable'.translate(context: context),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Column(
                        children: List.generate(
                          state.promocodeList.length,
                          (final int index) {
                            final Promocode promoCodeDetails = state.promocodeList[index];
                            return CustomInkWellContainer(
                              onTap: () {
                                UiUtils.showBottomSheet(
                                  context: context,
                                  child: Wrap(
                                    children: [
                                      PromocodeDetailsBottomSheet(
                                        promocodeDetails: promoCodeDetails,
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: CustomContainer(
                                margin: const EdgeInsetsDirectional.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,

                                  color: Theme.of(context).colorScheme.secondaryColor,
                                  borderRadius: borderRadiusOf10,
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .accentColor
                                          .withOpacity(0.5),),

                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(borderRadiusOf10),
                                      child: CustomCachedNetworkImage(
                                        networkImageUrl: promoCodeDetails.image!,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    const CustomSizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            promoCodeDetails.promoCode!,

                                              color: Theme.of(context).colorScheme.blackColor,
                                              fontWeight: FontWeight.bold,

                                            maxLines: 1,
                                          ),
                                          CustomText(
                                            promoCodeDetails.message!,

                                              color: Theme.of(context).colorScheme.lightGreyColor,
                                              fontSize: 12,

                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
            }
            return promoCodeLoadingShimmer(context: context);
          },
        ),
      );
}
