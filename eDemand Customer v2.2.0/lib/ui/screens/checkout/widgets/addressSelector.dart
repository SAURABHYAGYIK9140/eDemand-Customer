import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressSelector extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onEditButtonSelected;
  final VoidCallback? onDeleteButtonSelected;
  final String address,
      mobileNumber,
      addressPincodeAndCountry,
      addressAreaAndCity,
      addressType;
  final bool isAddressSelected;

  const AddressSelector(
      {super.key,
      this.onTap,
      required this.address,
      required this.mobileNumber,
      required this.addressPincodeAndCountry,
      required this.addressAreaAndCity,
      this.onEditButtonSelected,
      this.onDeleteButtonSelected,
      required this.addressType,
      required this.isAddressSelected});

  BoxDecoration selectedItemBorderStyle({required BuildContext context}) =>
      BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.lightGreyColor,
              blurRadius: 3)
        ],
        border: Border.all(color: Theme.of(context).colorScheme.blackColor),
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(borderRadiusOf10),
      );

  BoxDecoration normalBoxDecoration({required BuildContext context}) =>
      BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(borderRadiusOf10),
      );

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          width: 250,
          decoration: (isAddressSelected
              ? selectedItemBorderStyle(context: context)
              : normalBoxDecoration(context: context)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            mobileNumber,
                            color: Theme.of(context).colorScheme.blackColor,
                            maxLines: 1,
                          ),
                          CustomText(
                            filterAddressString(address),
                            color: Theme.of(context).colorScheme.blackColor,
                            maxLines: 2,
                          ),
                          CustomText(
                            filterAddressString(addressAreaAndCity),
                            color: Theme.of(context).colorScheme.blackColor,
                            maxLines: 1,
                          ),
                          CustomText(
                            filterAddressString(addressPincodeAndCountry),
                            color: Theme.of(context).colorScheme.blackColor,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomContainer(
                        height: 20,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton<int>(
                            padding: EdgeInsets.zero,
                            iconSize: 24,
                            color: Theme.of(context).colorScheme.accentColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(borderRadiusOf10),
                                bottomEnd: Radius.circular(borderRadiusOf10),
                                bottomStart: Radius.circular(borderRadiusOf10),
                              ),
                            ),
                            position: PopupMenuPosition.over,
                            onSelected: (final selected) {
                              if (selected == 1) {
                                onEditButtonSelected?.call();
                              }

                              if (selected == 2) {
                                onDeleteButtonSelected?.call();
                              }
                            },
                            itemBuilder: (final BuildContext context) => [
                              // popupmenu item 1
                              PopupMenuItem(
                                value: 1,
                                // row has two child icon and text.
                                child: CustomText(
                                  "edit".translate(context: context),
                                  color: AppColors.whiteColors,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                ),
                              ),
                              // popupmenu item 2
                              PopupMenuItem(
                                value: 2,
                                // row has two child icon and text
                                child: CustomText(
                                  "delete".translate(context: context),
                                  color: AppColors.whiteColors,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            offset: const Offset(0, 24),
                            elevation: 2,
                            child: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: <Widget>[
                        CustomText(
                          addressType,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.blackColor,
                        ),
                        const Spacer(),
                        if (isAddressSelected)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomText(
                                'serviceAddress'.translate(context: context),
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                              const CustomSizedBox(
                                width: 3,
                              ),
                              CustomContainer(
                                width: 25,
                                height: 25,
                                color:
                                    Theme.of(context).colorScheme.accentColor,
                                borderRadius: borderRadiusOf50,
                                child: Icon(
                                  Icons.done,
                                  color: AppColors.whiteColors,
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
