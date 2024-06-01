import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    required this.alreadyAddedQuantity,
    required this.serviceId,
    required this.maximumAllowedQuantity,
    final Key? key,
    this.height,
    this.width,
    this.isProviderAvailableAtLocation,
  }) : super(key: key);

  //
  final String serviceId;
  final String? isProviderAvailableAtLocation;
  final int maximumAllowedQuantity;
  final int alreadyAddedQuantity;
  final double? height;
  final double? width;

  @override
  Widget build(final BuildContext context) =>
      BlocConsumer<AddServiceIntoCartCubit, AddServiceIntoCartState>(
        listener:
            (final BuildContext context, final AddServiceIntoCartState addServiceIntoCartState) {
          if (addServiceIntoCartState is AddServiceIntoCartFailure) {
            UiUtils.showMessage(context, addServiceIntoCartState.errorMessage, MessageType.error);
          }
          if (addServiceIntoCartState is AddServiceIntoCartSuccess) {
            if (addServiceIntoCartState.error == false) {
              context.read<CartCubit>().updateCartDetails(addServiceIntoCartState.cartDetails);
            } else {
              UiUtils.showMessage(
                  context, addServiceIntoCartState.successMessage, MessageType.error);
            }
          }
        },
        builder:
            (final BuildContext context, final AddServiceIntoCartState addServiceIntoCartState) =>
                BlocConsumer<RemoveServiceFromCartCubit, RemoveServiceFromCartState>(
          listener: (context, RemoveServiceFromCartState removeServiceFromCartState) {
            if (removeServiceFromCartState is RemoveServiceFromCartFailure) {
              UiUtils.showMessage(
                context,
                removeServiceFromCartState.errorMessage,
                MessageType.error,
              );
            }
            if (removeServiceFromCartState is RemoveServiceFromCartSuccess) {
              if (removeServiceFromCartState.error == false) {
                context
                    .read<CartCubit>()
                    .updateCartDetails(removeServiceFromCartState.cartDetails!);
              }
            }
          },
          builder:
              (final BuildContext context, RemoveServiceFromCartState removeServiceFromCartState) {
            return alreadyAddedQuantity <= 0
                ? Stack(
                    children: [
                      CustomInkWellContainer(
                        onTap: () async {
                          if (isProviderAvailableAtLocation == "0") {
                            UiUtils.showMessage(context, "currentlyNotAvailableAtSelectedAddress",
                                MessageType.warning);
                            return;
                          }
                          final authStatus = context.read<AuthenticationCubit>().state;
                          if (authStatus is UnAuthenticatedState) {
                            //
                            await UiUtils.showAnimatedDialog(
                                context: context, child: const LogInAccountDialog());

                            return;
                          }

                          if (alreadyAddedQuantity < maximumAllowedQuantity) {
                            await context
                                .read<AddServiceIntoCartCubit>()
                                .addServiceIntoCart(serviceId: int.parse(serviceId), quantity: 1);
                          } else {
                            UiUtils.showMessage(
                              context,
                              'maximumLimitReached'.translate(context: context),
                              MessageType.warning,
                            );
                          }
                        },
                        child: CustomContainer(
                          height: height ?? 35,
                          width: width ?? 80,
                          color: isProviderAvailableAtLocation == "0"
                              ? Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.4)
                              : null,
                          borderRadius: borderRadiusOf5,
                          border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),

                          child:Center(
                            child: CustomText(
                              'add'.translate(context: context),

                              textAlign: TextAlign.left, color: isProviderAvailableAtLocation == "0"
                                ? Theme.of(context).colorScheme.lightGreyColor
                                : Theme.of(context).colorScheme.accentColor,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (addServiceIntoCartState is AddServiceIntoCartInProgress ||
                          removeServiceFromCartState is RemoveServiceFromCartInProgress)
                        CustomShimmerLoadingContainer(
                          borderRadius: borderRadiusOf5,
                          height: height ?? 35,
                          width: width ?? 80,
                        ),
                    ],
                  )
                : Stack(
                    children: [
                      CustomContainer(
                        height: height ?? 35,
                        width: width ?? 80,
                          color: Theme.of(context).colorScheme.secondaryColor,
                          borderRadius: borderRadiusOf5,
                          border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),

                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: CustomInkWellContainer(
                                  onTap: () {
                                    final authStatus = context.read<AuthenticationCubit>().state;
                                    if (authStatus is UnAuthenticatedState) {
                                      UiUtils.showAnimatedDialog(
                                          context: context, child: const LogInAccountDialog());
                                      return;
                                    }

                                    if (alreadyAddedQuantity > 1) {
                                      // Add service into cart
                                      context.read<AddServiceIntoCartCubit>().addServiceIntoCart(
                                            serviceId: int.parse(serviceId),
                                            quantity: alreadyAddedQuantity - 1,
                                          );
                                    } else {
                                      // remove service from cart
                                      context
                                          .read<RemoveServiceFromCartCubit>()
                                          .removeServiceFromCart(
                                            serviceId: int.parse(serviceId),
                                          );
                                    }
                                  },
                                  child: alreadyAddedQuantity == 1
                                      ? Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: Theme.of(context).colorScheme.accentColor,
                                        )
                                      : Icon(
                                          Icons.remove_outlined,
                                          size: 18,
                                          color: Theme.of(context).colorScheme.accentColor,
                                        ),
                                ),
                              ),
                              CustomText(
                                alreadyAddedQuantity.toString(),
                                  color: Theme.of(context).colorScheme.accentColor,
                                fontSize: 14,
                              ),
                              Expanded(
                                child: CustomInkWellContainer(
                                  onTap: () {
                                    if (alreadyAddedQuantity < maximumAllowedQuantity) {
                                      context.read<AddServiceIntoCartCubit>().addServiceIntoCart(
                                            serviceId: int.parse(serviceId),
                                            quantity: alreadyAddedQuantity + 1,
                                          );
                                    } else {
                                      UiUtils.showMessage(
                                        context,
                                        'maximumLimitReached'.translate(context: context),
                                        MessageType.warning,
                                      );
                                    }
                                  },
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.accentColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      if (addServiceIntoCartState is AddServiceIntoCartInProgress ||
                          removeServiceFromCartState is RemoveServiceFromCartInProgress)
                        CustomShimmerLoadingContainer(
                          borderRadius: borderRadiusOf5,
                          height: height ?? 35,
                          width: width ?? 80,
                        ),
                    ],
                  );
          },
        ),
      );
}
