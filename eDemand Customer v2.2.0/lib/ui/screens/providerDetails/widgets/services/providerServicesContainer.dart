import 'package:e_demand/app/generalImports.dart';import 'package:flutter/material.dart';

class ProviderServicesContainer extends StatelessWidget {
  final List<Services> servicesList;
  final String providerID;
  final String isProviderAvailableAtLocation;
  final bool isLoadingMoreData;

  const ProviderServicesContainer(
      {super.key,
      required this.servicesList,
      required this.providerID,
      required this.isLoadingMoreData,
      required this.isProviderAvailableAtLocation});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey("services"),
      padding: EdgeInsets.only(
        top: 5,
        left: 15,
        right: 15,
        bottom: context.read<CartCubit>().getProviderIDFromCartData() == '0'
            ? 0
            : bottomNavigationBarHeight + 10,
      ),
      shrinkWrap: true,
      //physics: const ClampingScrollPhysics(),
      itemCount: servicesList.length + (isLoadingMoreData ? 1 : 0),
      itemBuilder: (final BuildContext context, final index) {
        if (index >= servicesList.length) {
          return Center(
            child: CustomCircularProgressIndicator(color: Theme.of(context).colorScheme.accentColor),
          );
        }
        return ServiceDetailsCard(
          isProviderAvailableAtLocation: isProviderAvailableAtLocation,
          services: servicesList[index],
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
                      serviceId: servicesList[index].id ?? "",
                      providerId: providerID,
                    ),
                    child: ServiceDetailsBottomSheet(
                      serviceDetails: servicesList[index],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
