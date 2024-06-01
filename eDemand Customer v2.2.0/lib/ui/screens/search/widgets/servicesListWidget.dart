import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/searchServicesWithProvidersCubit.dart';
import 'package:e_demand/ui/widgets/customLoadingMoreContainer.dart';
import 'package:flutter/material.dart';

class ServicesListWidget extends StatelessWidget {
  final ScrollController servicesScrollController;
  final VoidCallback onTapRetry;
  final VoidCallback onErrorButtonPressed;

  const ServicesListWidget(
      {super.key,
      required this.servicesScrollController,
      required this.onTapRetry,
      required this.onErrorButtonPressed});

  Widget _getServicesList(BuildContext context,
      {required final List<Providers> providerList,
      required final bool isLoadingMoreData,
      required final bool isLoadingMoreError}) {
    /* If data available in cart then it will return providerId,
       and if it's returning 0 means cart is empty
       so we do not need to add extra bottom height for padding
                            */
    final cartButtonHeight = context.read<CartCubit>().getProviderIDFromCartData() == '0' ? 0 : 20;
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      controller: servicesScrollController,
      padding: EdgeInsets.only(
        bottom: getScrollViewBottomPadding(context) + cartButtonHeight,
        right: 15,
        left: 15,
        top: 10,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: providerList.length + (isLoadingMoreData || isLoadingMoreError ? 1 : 0),
      itemBuilder: (final BuildContext context, final int index) {
        if (index >= providerList.length) {
          return CustomLoadingMoreContainer(
            isError: isLoadingMoreError,
            onErrorButtonPressed: onErrorButtonPressed,
          );
        }
        return CustomContainer(
          width: MediaQuery.sizeOf(context).width,
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: borderRadiusOf10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CustomInkWellContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      providerRoute,
                      arguments: {"providerId": providerList[index].id},
                    );
                  },
                  child: Row(
                    children: [
                      CustomContainer(
                        borderRadius: borderRadiusOf5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadiusOf5),
                          child: CustomCachedNetworkImage(
                            networkImageUrl: providerList[index].image ?? "",
                            width: 35,
                            height: 35,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            providerList[index].partnerName ?? "",
                            color: Theme.of(context).colorScheme.blackColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 12,
                            textAlign: TextAlign.left,
                          ),
                          CustomText(
                            providerList[index].companyName ?? "",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              CustomSizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shrinkWrap: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: providerList[index].services?.length ?? 0,
                  itemBuilder: (context, serviceIndex) {
                    if (providerList[index].services == null) {
                      return Container();
                    }
                    return CustomSizedBox(
                      width: 270,
                      child: _buildServiceListItem(
                        context,
                        services: providerList[index].services![serviceIndex],
                        onTap: () {
                          UiUtils.showBottomSheet(
                            context: context,
                            enableDrag: true,
                            child: Wrap(
                              children: [
                                BlocProvider(
                                  lazy: false,
                                  create: (context) => ServiceReviewCubit(
                                    reviewRepository: ReviewRepository(),
                                    serviceId: providerList[index].services![serviceIndex].id ?? "",
                                    providerId: providerList[index].id,
                                  ),
                                  child: ServiceDetailsBottomSheet(
                                    serviceDetails: providerList[index].services![serviceIndex],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                ),
              ),
              const CustomSizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocConsumer<SearchServicesCubit, SearchServicesState>(
          listener: (final BuildContext context, final searchState) {
            if (searchState is SearchServicesFailureState) {
              UiUtils.showMessage(
                  context, searchState.errorMessage.translate(context: context), MessageType.error);
            }
          },
          builder: (final BuildContext context, final searchState) {
            if (searchState is SearchServicesFailureState) {
              return Center(
                child: ErrorContainer(
                  errorMessage: 'somethingWentWrong'.translate(context: context),
                  onTapRetry: onTapRetry,
                  showRetryButton: true,
                ),
              );
            } else if (searchState is SearchServicesSuccessState) {
              if (searchState.providersWithServicesList.isEmpty) {
                return NoDataContainer(
                  titleKey: 'noServicesFound'.translate(context: context),
                );
              }
              return _getServicesList(context,
                  isLoadingMoreError: searchState.isLoadingMoreError,
                  providerList: searchState.providersWithServicesList,
                  isLoadingMoreData: searchState.isLoadingMore);
            } else if (searchState is SearchServicesProgressState) {
              return const SingleChildScrollView(
                  child: ProviderListShimmerEffect(
                showTotalProviderContainer: false,
              ));
            }
            return NoDataContainer(
              titleKey: "typeToSearch".translate(context: context),
              showRetryButton: false,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10, right: 5, left: 5),
          child: Align(alignment: Alignment.bottomCenter, child: CartSubDetailsContainer()),
        ),
      ],
    );
  }

  Widget _buildServiceListItem(BuildContext context,
      {required Services services, required VoidCallback onTap}) {
    return CustomContainer(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: borderRadiusOf10,
      border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.3)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInkWellContainer(
            onTap: onTap,
            child: CustomSizedBox(
              height: 70,
              width: 70,
              child: Stack(
                children: [
                  Align(
                    child: CustomImageContainer(
                      height: 70,
                      width: 70,
                      borderRadius: borderRadiusOf10,
                      imageURL: services.imageOfTheService!,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: CustomContainer(
                      width: 70,
                      height: 70,
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
                          fontSize: 14,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInkWellContainer(
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        services.title!,
                        maxLines: 1,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: CustomText(
                          "${services.numberOfMembersRequired} ${"person".translate(context: context)} | ${services.duration} min",
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.lightGreyColor,
                        ),
                      ),
                    ],
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
                                  color:
                                      Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                CustomText(
                                  ' (${services.numberOfRatings!})',
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.7),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
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
                          padding: const EdgeInsetsDirectional.only(bottom: 5),
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
                              isProviderAvailableAtLocation: "1",
                              maximumAllowedQuantity: int.parse(services.maxQuantityAllowed!),
                              alreadyAddedQuantity: int.parse(
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
}
